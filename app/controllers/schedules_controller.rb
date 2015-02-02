class SchedulesController < ApplicationController
  include ApplicationHelper
  include SchedulesHelper
  
  layout "application_angular", only: [:edit, :new]
  before_filter :require_admin_user, except: [ :scheduled_for_job ]
  before_filter :initialize_collections, except: [ :schedule_conflicts ]

  def index
    from_time_str = params[:from_date].blank? ? nil : "#{params[:from_date]} 00:00:00 UTC"
    to_time_str = params[:to_date].blank? ? nil : "#{params[:to_date]} 00:00:00 UTC"
    
    @from_time = (Time.parse(from_time_str) rescue nil) || Time.now.beginning_of_month
    @to_time = (Time.parse(to_time_str).end_of_day rescue nil) || Time.now.end_of_month

    params[:unit] = "month" if params[:unit].blank?
    @schedules = schedule_query.sort_by(&:from_time)
    @schedules_grid = schedules_grid
    @schedules_grid.build
    
    @user = User.find(params[:user_id]) unless params[:user_id].blank?
    @job = Job.find(params[:job_id]) unless params[:job_id].blank?

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def search
    Date.beginning_of_week = :sunday
    @from_time = (Time.parse("#{params[:from_date]} 00:00:00 UTC") rescue nil) || Time.now.beginning_of_month
    @to_time = (Time.parse("#{params[:to_date]} 00:00:00 UTC").end_of_day rescue nil) || Time.now.end_of_month
    update_date_range
    
    unless params[:selected_tab] == "Calendar"
      @schedules = schedule_query.sort_by(&:from_time)
      @schedules_grid = schedules_grid
      @schedules_grid.build
      
      user_ids = @schedules_grid.source_data.map(&:user_id).uniq
      job_ids = @schedules_grid.source_data.map(&:job_id).uniq
      @schedules = schedule_query.where(user_id: user_ids, job_id: job_ids).sort_by(&:from_time)
    end
    
    @user = User.find(params[:user_id]) rescue nil
    @job = Job.find(params[:job_id]) rescue nil
    
    render :index
  end

  def show
    @schedule = Schedule.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @schedule.to_json(include: [:job, :user]) }
    end
  end

  def new
    respond_to do |format|
      format.html
      format.json { 
        if params[:future_schedule_id]
          @future_schedule = FutureSchedule.find(params[:future_schedule_id]) rescue nil
        end

        @schedule = Schedule.new
        unless @future_schedule.nil?
          @schedule.from_time = @future_schedule.from_time
          @schedule.to_time = @future_schedule.to_time
          @schedule.job_id = @future_schedule.job_id
          @schedule.through_date = @future_schedule.through_date
        end

        render json: @schedule.as_json(methods: :time_ranges, include: [:job]) 
      }
    end
  end

  def edit
    @schedule = Schedule.find(params[:id])
    
    @schedule_time_ranges = [
      {
        "from_time_date" => default_schedule_date(:from_time),
        "from_time_time" => default_from_time(:from_time),
        "to_time_date" => default_schedule_date(:to_time),
        "to_time_time" => default_from_time(:to_time),
        "total_hours" => @schedule.hours,
        "through_date" => default_schedule_date(:through_date),
        "day_of_week" => Date::DAYNAMES[@schedule.from_time.wday]
      }
    ]
    
    respond_to do |format|
      format.html
      format.json { render json: @schedule.to_json(include: { job: { customer: {} } }, methods: :time_ranges) }
    end
  end

  def get_available_employees

    # "(from_time >= ? and from_time <= ?) or (to_time >= ? and to_time <= ?)", @from_time, @to_time, @from_time, @to_time
    schedule_hash = JSON.parse(params[:schedule])
    schedule_blocks = get_schedule_blocks(schedule_hash['time_ranges'])

    base_sql = 'select distinct "users".* from "users" left join "schedules" on "schedules".user_id = "users".id  '

    # and () or () or ()
    filter_time_statements = []
    filter_time_times = []
    schedule_blocks.each do |schedule_block|
      filter_time_statements << '((from_time >= ? and from_time <= ?) or (to_time >= ? and to_time <= ?))'
      from_time = schedule_block[:from_time] - 5.hours - 59.minutes - 59.seconds
      to_time = schedule_block[:to_time] + 6.hours + 59.minutes + 59.seconds
      filter_time_times << from_time
      filter_time_times << to_time
      filter_time_times << from_time
      filter_time_times << to_time
    end
    if filter_time_times.size > 0
      base_sql += " and (#{filter_time_statements.join(' or ')}) where \"schedules\".id is null and \"users\".archived = 'f' "
    else
      base_sql += 'where "users".archived = \'f\''
    end

    respond_to do |format|
      format.json {
        users = User.find_by_sql([base_sql, *filter_time_times.flatten])
        render :json => users.to_json(:include => [:user_type], :methods => [:skills_list]), :status => :ok
      }
    end
  end

  def create_schedule
    schedule_hash = JSON.parse(params[:schedule])
    users_selected = JSON.parse(params[:users_selected])
    
    schedule_blocks = get_schedule_blocks(schedule_hash['time_ranges'])
    schedules = []
    
    employee_ids = users_selected.map {|user| user["id"] }
    
    if schedule_blocks.count == 0 || employee_ids.count == 0
      respond_to do |format|
        schedule_hash['errors'] = ['The schedule is incomplete']
        format.json { render json: schedule_hash, status: :bad_request }
      end
      return
    end
    
    employee_ids.each do |employee_id|
      schedule_blocks.each do |schedule_block|
        schedules << Schedule.new({ job_id: schedule_hash["job"].try(:[], "id") }.merge(
          user_id: employee_id, 
          from_time: schedule_block[:from_time], 
          to_time: schedule_block[:to_time]
        ))
      end
    end

    conflicts = ScheduleConflictChecker.check_schedule_for_conflicts( schedules )

    schedules.each do |s|
      if !s.valid? || conflicts[:errors].count > 0
        unique_errors = Set.new
        conflicts[:errors].each {|error_message| unique_errors << error_message }
        s.errors.full_messages.each {|error_message| unique_errors << error_message }
        schedule_hash["errors"] = unique_errors.to_a

        respond_to do |format|
          format.json { render json: schedule_hash, status: :bad_request }
        end
        return
      end
    end
    schedules.each {|s| s.save }
    
    employee_ids.each do |employee_id|
      ScheduleMailer.schedule_created(employee_id, schedules.first.job.id, schedule_blocks).deliver
    end
    
    respond_to do |format|
      format.json { head :ok }
    end
  end
  
  def update_schedule
    schedule_hash = JSON.parse(params[:schedule])
    
    @schedule = Schedule.find(schedule_hash["id"])
    
    time_range = schedule_hash["time_ranges"].first
    
    @schedule.from_time = Time.parse(time_range["from_time"]) rescue nil
    @schedule.to_time = Time.parse(time_range["to_time"]) rescue nil
    @schedule.job_id = schedule_hash["job"]["id"] rescue nil

    conflicts = ScheduleConflictChecker.check_schedule_for_conflicts([@schedule])

    if conflicts[:errors].count == 0 && @schedule.valid?
      respond_to do |format|
        @schedule.save
        format.json { head :ok }
      end
    else
      unique_errors = Set.new
      conflicts[:errors].each {|error_message| unique_errors << error_message }
      @schedule.errors.full_messages.each {|error_message| unique_errors << error_message }
      schedule_hash["errors"] = unique_errors.to_a
      
      respond_to do |format|
        format.json { render json: schedule_hash, status: :bad_request }
      end
    end
  end
  
  def create_pending_schedule
    schedule_hash = JSON.parse(params[:schedule])
    
    time_range = schedule_hash["time_ranges"].first
    
    @future_schedule = FutureSchedule.new
    @future_schedule.from_time = Time.parse(time_range["from_time"]) rescue nil
    @future_schedule.to_time = Time.parse(time_range["to_time"]) rescue nil
    @future_schedule.job_id = schedule_hash["job"]["id"] rescue nil
    @future_schedule.through_date = Time.parse(time_range["through_date"]) rescue nil
    
    if @future_schedule.valid?
      respond_to do |format|
        @future_schedule.save
        format.json { head :ok }
      end
    else
      unique_errors = Set.new
      @future_schedule.errors.full_messages.each {|error_message| unique_errors << error_message }
      schedule_hash["errors"] = unique_errors.to_a
      
      respond_to do |format|
        format.json { render json: schedule_hash, status: :bad_request }
      end
    end
  end
  
  def update_pending_schedule
    schedule_hash = JSON.parse(params[:schedule])
    
    @future_schedule = FutureSchedule.find(schedule_hash["future_schedule_id"])
    
    time_range = schedule_hash["time_ranges"].first

    @future_schedule.from_time = Time.parse(time_range["from_time"]) rescue nil
    @future_schedule.to_time = Time.parse(time_range["to_time"]) rescue nil
    @future_schedule.job_id = schedule_hash["job"]["id"] rescue nil
    @future_schedule.through_date = Time.parse(time_range["through_date"]) rescue nil
    
    if @future_schedule.valid?
      respond_to do |format|
        @future_schedule.save
        format.json { head :ok }
      end
    else
      unique_errors = Set.new
      @future_schedule.errors.full_messages.each {|error_message| unique_errors << error_message }
      schedule_hash["errors"] = unique_errors.to_a
      
      respond_to do |format|
        format.json { render json: schedule_hash, status: :bad_request }
      end
    end
  end
  
  def delete_pending_schedule
    schedule_hash = JSON.parse(params[:schedule])
    begin
      @future_schedule = FutureSchedule.find(schedule_hash["future_schedule_id"])
      @future_schedule.delete
    rescue StandardError => e
      
    end
    head :ok
  end

  def create
    @schedule = Schedule.new({ job_id: params[:schedule][:job_id] })
    @schedule_time_ranges = params[:schedule_item].map {|k, v| v }
    
    if params[:commit].try(:downcase) == "create pending schedule"
      @future_schedule = FutureSchedule.new
      @future_schedule.from_time = "#{@schedule_time_ranges[0][:from_time_date]} #{@schedule_time_ranges[0][:from_time_time]}"
      @future_schedule.to_time = "#{@schedule_time_ranges[0][:to_time_date]} #{@schedule_time_ranges[0][:to_time_time]}"
      @future_schedule.job_id = @schedule.job_id
      @future_schedule.through_date = @schedule_time_ranges[0][:through_date]
      
      if @future_schedule.valid?
        respond_to do |format|
          @future_schedule.save
          format.html { redirect_to new_schedule_path(future_schedule_id: @future_schedule.id), notice: "Pending schedule was successfully created." }
        end
      else
        respond_to do |format|
          format.html { render action: "new" }
        end
      end
      return
    elsif params[:commit].try(:downcase) == "update pending schedule"
      @future_schedule = FutureSchedule.find(params[:future_schedule_id])
      unless @future_schedule.nil?
        @future_schedule.from_time = "#{@schedule_time_ranges[0][:from_time_date]} #{@schedule_time_ranges[0][:from_time_time]}"
        @future_schedule.to_time = "#{@schedule_time_ranges[0][:to_time_date]} #{@schedule_time_ranges[0][:to_time_time]}"
        @future_schedule.job_id = @schedule.job_id
        @future_schedule.through_date = @schedule_time_ranges[0][:through_date]
      end
      if @future_schedule.valid?
        @future_schedule.save
        respond_to do |format|
          format.html { redirect_to new_schedule_path(future_schedule_id: @future_schedule.id), notice: "Pending schedule was successfully updated." }
        end
      else
        respond_to do |format|
          format.html { render action: "new" }
        end
      end
      return
    elsif params[:commit].try(:downcase) == "delete pending schedule"
      @future_schedule = FutureSchedule.find(params[:future_schedule_id])
      unless @future_schedule.nil?
        @future_schedule.delete
      end
      respond_to do |format|
        format.html { redirect_to new_schedule_path, notice: "Pending schedule was successfully deleted." }
      end
      return
    else
      
    end
  end

  def update
    @schedule = Schedule.find(params[:id])
    @schedule_time_ranges = [ params[:schedule_item]["0"] ]
    @schedule.job_id = params[:schedule][:job_id]
    @schedule.from_time = "#{@schedule_time_ranges.first["from_time_date"]} #{@schedule_time_ranges.first["from_time_time"]}"
    @schedule.to_time = "#{@schedule_time_ranges.first["to_time_date"]} #{@schedule_time_ranges.first["to_time_time"]}"

    respond_to do |format|
      if @schedule.valid?
        @schedule.save
        format.html { 
          redirect_to params[:return_path] || @schedule, notice: 'Schedule was successfully updated.' 
        }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @schedule = Schedule.find(params[:id])
    @schedule.destroy

    respond_to do |format|
      format.html { redirect_to params[:return_path] || schedules_url }
      format.json { head :no_content }
    end
  end
  
  def scheduled_for_job
    schedules = Schedule.where(job_id: params[:job_id])
    schedules = schedules.where("from_time >= ? AND from_time < ?", Date.parse(params[:schedule_date]), Date.parse(params[:schedule_date]) + 1.day)
    @job = Job.find(params[:job_id])
    @schedules = schedules.detect {|s| s.user_id == current_user.id } ? schedules : []
  end
  
  def schedule_conflicts
    @errors = []
    @warnings = []
    
    schedule_hash = JSON.parse(params[:schedule])
    users_selected = JSON.parse(params[:users_selected])
    
    schedule_blocks = get_schedule_blocks(schedule_hash["time_ranges"])
    
    schedule = Schedule.find(schedule_hash['id']) unless schedule_hash['id'].blank?
    
    if !schedule.nil?
      schedule.from_time = schedule_blocks.first[:from_time]
      schedule.to_time = schedule_blocks.first[:to_time]
      
      conflicts = ScheduleConflictChecker.check_schedule_for_conflicts([schedule])
      conflicts[:errors].each {|error| @errors << error}
      conflicts[:warnings].each {|warning| @warnings << warning}
    else
      users_selected.each do |user_hash|
        schedules = []
        schedule_blocks.each do |schedule_block|
          schedules << Schedule.new({ job_id: schedule_hash["job_id"] }.merge(
            user_id: user_hash["id"], 
            from_time: schedule_block[:from_time], 
            to_time: schedule_block[:to_time]
          ))
        end
        
        conflicts = ScheduleConflictChecker.check_schedule_for_conflicts(schedules)
        conflicts[:errors].each {|error| @errors << error}
        conflicts[:warnings].each {|warning| @warnings << warning}
      end
    end
    
    respond_to do |format|
      format.json { render json: {errors: @errors, warnings: @warnings} }
    end
  end
  
  def get_schedule_blocks(time_ranges)
    schedule_blocks = []
    begin
      if time_ranges.size == 1
        from_time = Time.parse(time_ranges[0]["from_time"])
        to_time = Time.parse(time_ranges[0]["to_time"])
        through_date = Time.parse(time_ranges[0]["through_date"]).end_of_day
        
        while from_time <= through_date
          schedule_blocks << {
            from_time: from_time,
            to_time: to_time
          }
          from_time += 1.day
          to_time += 1.day
        end
        
      else
        time_ranges.each do |range|
          schedule_blocks << {
            from_time: Time.parse(range["from_time"]),
            to_time: Time.parse(range["to_time"])
          }
        end
      end
    rescue
      
    end
    
    schedule_blocks
  end
  
  def grouped_by_job_id
    colors = [
      "rgba( 0, 66, 255, 0.5 ) !important",
      "rgba( 0, 230, 25, 0.5 ) !important",
      "rgba( 0, 255, 115, 0.5 ) !important",
      "rgba( 48, 255, 0, 0.5 ) !important",
      "rgba( 207, 255, 0, 0.5 ) !important",
      "rgba( 255, 197, 0, 0.5 ) !important",
      "rgba( 255, 115, 0, 0.5 ) !important",
      "rgba( 255, 33, 0, 0.5 ) !important",
      "rgba( 0, 148, 255, 0.5 ) !important",
      "rgba( 0, 255, 197, 0.5 ) !important",
      "rgba( 0, 255, 33, 0.5 ) !important",
      "rgba( 128, 255, 0, 0.5 ) !important",
      "rgba( 255, 238, 0, 0.5 ) !important",
      "rgba( 255, 156, 0, 0.5 ) !important",
      "rgba( 255, 74, 0, 0.5 ) !important"
    ]
    @schedules = []
    job_color = {}
    color_index = 0
    
    min_time = Time.at(params[:start].to_i)
    max_time = Time.at(params[:end].to_i)
    
    query = FutureSchedule.where(["from_time >= ? AND from_time <= ?", min_time, max_time])
    query.each do |result|
      if job_color[result.job_id].nil?
        job_color[result.job_id] = color_index
        color_index += 1
        color_index = 0 if color_index >= colors.length
      end
      
      return_params = params.reject {|k, v| k == "format" }
      
      @schedules << result.to_schedule_event(colors[job_color[result.job_id]], new_schedule_path(future_schedule_id: result.id, return_path: schedules_path(return_params)))
      
    end
    
    
    
    query = Schedule.select(:job_id, :from_time).order(job_id: :asc)
    query = query.where([
      "((from_time >= ? AND from_time <= ?) OR (to_time >= ? AND to_time <= ?))", 
      min_time,
      max_time,
      min_time,
      max_time
    ])
    
    schedules = query.map {|s| {job_id: s.job_id, from_time: s.from_time.strftime("%Y-%m-%d 00:00:00")} }.uniq.map {|r| Schedule.new(job_id: r[:job_id], from_time: r[:from_time]) }
    
    url_params = params.reject {|k, v| ["format"].include?(k) }
    
    schedules.each do |result|
      if job_color[result.job_id].nil?
        job_color[result.job_id] = color_index
        color_index += 1
        color_index = 0 if color_index >= colors.length
      end
      @schedules << result.to_schedule_event_grouped_by_job_id(colors[job_color[result.job_id]])
    end
    
    respond_to do |format|
      format.json { render json: @schedules }
    end
  end
  
  def delete_multiple
    Schedule.where(id: params[:schedule].keys).delete_all
    redirect_to(params[:return_path])
  end
  
  private
  def initialize_collections
    @users = User.where(archived: false).sort_by{|u| u.full_name }.collect {|u| [u.full_name, u.id] }
    @jobs = Job.where(archived: false).load.sort_by{|j| "#{!j.customer.nil? ? j.customer.try(:name) + ": " : ""}#{j.name}" }.collect {|j| ["#{!j.customer.nil? ? j.customer.try(:name) + ": " : ""}#{j.name}", j.id] }
  end
  
  def schedules_grid
    PivotTable::Grid.new {|g| g.source_data = schedules_data; g.column_name = :job_id; g.row_name = :user_id; g.value_name = :hours }
  end
  
  def schedules_data
    jobs_users = {}
    schedule_query.each do |s|
      jobs_users[s.job_id] ||= {}
      jobs_users[s.job_id][s.user_id] ||= 0
      jobs_users[s.job_id][s.user_id] += s.hours
    end
    sd = []
    jobs_users.each do |job_id, users|
      jobs_users[job_id].each do |user_id, hours|  
        sd << OpenStruct.new(job_id: job_id, user_id: user_id, hours: hours)
      end
    end
    
    sd = filter_hours_per(sd)
    
    sd
  end
  
  def filter_hours_per(schedule_data)
    filter_hours = params[:filter_hours].try(:to_f)
    
    unless filter_hours.nil?
      if params[:filter_hours_per] == "Employee"
        hours = {}
        schedule_data.each do |sd|
          hours[sd.user_id] ||= 0
          hours[sd.user_id] += sd.hours
        end
        
        user_ids = hours.find_all {|k, v| v.send(params[:filter_hours_sign].to_sym, filter_hours) }.map {|v| v[0] }
        schedule_data.delete_if do |sd|
          !user_ids.include?(sd.user_id)
        end
      elsif params[:filter_hours_per] == "Job"
        hours = {}
        schedule_data.each do |sd|
          hours[sd.job_id] ||= 0
          hours[sd.job_id] += sd.hours
        end
        
        job_ids = hours.find_all {|k, v| v.send(params[:filter_hours_sign].to_sym, filter_hours) }.map {|v| v[0] }
        schedule_data.delete_if do |sd|
          !job_ids.include?(sd.job_id)
        end
      else
        schedule_data
      end
    else
      schedule_data
    end
  end
  
  def schedule_query
    schedule_query = Schedule.where(["(from_time >= ? and from_time <= ?) or (to_time >= ? and to_time <= ?)", @from_time, @to_time, @from_time, @to_time]).joins(:user, :job).includes(:user, :job)
    schedule_query = schedule_query.where(job_id: params[:job_id]) unless params[:job_id].blank?
    schedule_query = schedule_query.where(user_id: params[:user_id]) unless params[:user_id].blank?
    schedule_query = case
      when params[:archived] == "jobs" then schedule_query.where("users.archived" => false)
      when params[:archived] == "employees" then schedule_query.where("jobs.archived" => false)
      when params[:archived] == "all" then schedule_query
      else schedule_query.where("jobs.archived" => false, "users.archived" => false)
    end
    schedule_query
  end
  
  def update_date_range
    case params[:unit]
    when "today"
      @from_time = Time.now.beginning_of_day
      @to_time = Time.now.end_of_day
    when "month"
      @from_time = @from_time.beginning_of_month
      @to_time = @from_time.end_of_month
    when "week"
      @from_time = @from_time.beginning_of_week
      @to_time = @from_time.end_of_week
    when "day"
      @to_time = @from_time.end_of_day
    else
      params[:unit] = "day" if @from_time == @to_time
      params[:unit] = "month" if @from_time == @from_time.beginning_of_month && @to_time == @from_time.end_of_month
      params[:unit] = "week" if @from_time == @from_time.beginning_of_week && @to_time == @from_time.end_of_week
      params[:unit] = "today" if @from_time == Time.now.beginning_of_day && @to_time == Time.now.end_of_day
    end
  end
end

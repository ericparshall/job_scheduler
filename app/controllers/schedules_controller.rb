class SchedulesController < ApplicationController
  include ApplicationHelper
  include SchedulesHelper
  
  before_filter :require_admin_user, except: [ :scheduled_for_job ]
  before_filter :initialize_collections, except: [ :schedule_conflicts ]

  def index
    @from_time = (Time.parse("#{params[:from_date]} 00:00:00 UTC") rescue nil) || Time.now.beginning_of_month
    @to_time = (Time.parse("#{params[:to_date]} 00:00:00 UTC").end_of_day rescue nil) || Time.now.end_of_month
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
      format.json { render json: @schedule }
    end
  end

  def new
    params[:user_ids] ||= {}
    params[:user_ids][params[:employee_id]] = User.find(params[:employee_id]).full_name unless params[:employee_id].blank?
    @schedule = Schedule.new
    
    if params[:future_schedule_id]
      @future_schedule = FutureSchedule.find(params[:future_schedule_id]) rescue nil
    end
    
    unless @future_schedule.nil?
      @schedule.from_time = @future_schedule.from_time
      @schedule.to_time = @future_schedule.to_time
      @schedule.job_id = @future_schedule.job_id
    end
    
    @schedule_time_ranges = [
      {
        "from_time_date" => default_schedule_date(:from_time),
        "from_time_time" => default_from_time(:from_time),
        "to_time_date" => default_schedule_date(:to_time),
        "to_time_time" => default_from_time(:to_time),
        "total_hours" => @schedule.hours,
        "through_date" => default_schedule_date(:through_date),
        "day_of_week" => ""
      }
    ]

    respond_to do |format|
      format.html
      format.json { render json: @schedule }
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
      schedule_blocks = get_schedule_blocks(params[:schedule_item])
      schedules = []
      
      employee_ids = params[:user_ids].map {|k, v| k } rescue []
      employee_ids.each do |employee_id|
        schedule_blocks.each do |schedule_block|
          schedules << Schedule.new({ job_id: params[:schedule][:job_id] }.merge(
            user_id: employee_id, 
            from_time: schedule_block[:from_time], 
            to_time: schedule_block[:to_time]
          ))
        end
      end
        
      schedules.each do |s|
        if !s.valid?
          @schedule = s
          render action: "new"
          return
        end
      end
      schedules.each {|s| s.save }
      
      employee_ids.each do |employee_id|
        ScheduleMailer.schedule_created(employee_id, params[:schedule][:job_id], schedule_blocks).deliver
      end
      
      respond_to do |format|
        format.html { redirect_to params[:return_path] || @schedule, notice: 'Schedule(s) was successfully created.' }
      end
      return
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
    schedule_blocks = get_schedule_blocks(params["schedule_item"])
    
    schedule = Schedule.find(params[:schedule_id]) unless params[:schedule_id].blank?
    
    if !schedule.nil?
      schedule.from_time = schedule_blocks.first[:from_time]
      schedule.to_time = schedule_blocks.first[:to_time]
      
      conflicts = ScheduleConflictChecker.check_schedule_for_conflicts([schedule])
      conflicts[:errors].each {|error| @errors << error}
      conflicts[:warnings].each {|warning| @warnings << warning}
    else
      employee_ids = params[:user_ids].map {|k, v| k } rescue []
      employee_ids.each do |employee_id|
        schedules = []
        schedule_blocks.each do |schedule_block|
          schedules << Schedule.new({ job_id: params[:schedule][:job_id] }.merge(
            user_id: employee_id, 
            from_time: schedule_block[:from_time], 
            to_time: schedule_block[:to_time]
          ))
        end
        
        conflicts = ScheduleConflictChecker.check_schedule_for_conflicts(schedules)
        conflicts[:errors].each {|error| @errors << error}
        conflicts[:warnings].each {|warning| @warnings << warning}
      end
    end
    
    render layout: false
  end
  
  def get_schedule_blocks(schedule_item)
    schedule_blocks = []
    begin
      if schedule_item.size == 1
        start_date = Date.parse(schedule_item["0"]["from_time_date"])
        end_date = Date.parse(schedule_item["0"]["to_time_date"])
        through_date = Date.parse(schedule_item["0"]["through_date"]) rescue start_date
        while start_date <= through_date
          schedule_blocks << {
            from_time: Time.parse("#{start_date.strftime("%m/%d/%Y")} #{schedule_item["0"]["from_time_time"]} UTC"),
            to_time: Time.parse("#{end_date.strftime("%m/%d/%Y")} #{schedule_item["0"]["to_time_time"]} UTC")
          }
          start_date += 1.day
          end_date += 1.day
        end
      else
        schedule_item.each do |index, range|
          schedule_blocks << {
            from_time: Time.parse("#{range["from_time_date"]} #{range["from_time_time"]} UTC"),
            to_time: Time.parse("#{range["to_time_date"]} #{range["to_time_time"]} UTC")
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
      @to_time = @from_time
    else
      params[:unit] = "day" if @from_time == @to_time
      params[:unit] = "month" if @from_time == @from_time.beginning_of_month && @to_time == @from_time.end_of_month
      params[:unit] = "week" if @from_time == @from_time.beginning_of_week && @to_time == @from_time.end_of_week
      params[:unit] = "today" if @from_time == Time.now.beginning_of_day && @to_time == Time.now.end_of_day
    end
  end
end

class SchedulesController < ApplicationController
  before_filter :require_admin_user, except: [ :scheduled_for_job ]
  before_filter :initialize_collections, except: [ :schedule_conflicts ]

  def index
    @from_time = (Time.parse(params[:from_date]) rescue nil) || Time.now.beginning_of_month
    @to_time = (Time.parse(params[:to_date]).end_of_day rescue nil) || Time.now.end_of_month
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
    @from_time = (Time.parse(params[:from_date]) rescue nil) || Time.now.beginning_of_month
    @to_time = (Time.parse(params[:to_date]).end_of_day rescue nil) || Time.now.end_of_month
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
    @schedule_time_ranges = [
      {
        "from_time_date" => "",
        "from_time_time" => "",
        "to_time_date" => "",
        "from_time_time" => "",
        "total_hours" => "",
        "through_date" => "",
        "day_of_week" => ""
      }
    ]
    if params[:future_schedule_id]
      @future_schedule = FutureSchedule.find(params[:future_schedule_id]) rescue nil
    end
    
    unless @future_schedule.nil?
      @schedule.from_time = @future_schedule.from_time
      @schedule.to_time = @future_schedule.to_time
      @schedule.job_id = @future_schedule.job_id
    end

    respond_to do |format|
      format.html
      format.json { render json: @schedule }
    end
  end

  def edit
    @schedule = Schedule.find(params[:id])
  end

  def create
    @schedule = Schedule.new(schedule_params)
    
    from_date = Date.parse(params[:schedule][:schedule_date]) rescue nil
    to_date = Date.parse(params[:schedule][:through_schedule_date]) rescue nil
    
    to_date = from_date if to_date.nil?
    
    unless from_date.nil? || to_date.nil?
      if params[:commit].try(:downcase) == "create pending schedule"
        @future_schedule = FutureSchedule.new
        @future_schedule.from_date = from_date
        @future_schedule.to_date = to_date
        @future_schedule.from_time = @schedule.from_time
        @future_schedule.to_time = @schedule.to_time
        @future_schedule.job_id = @schedule.job_id
        @future_schedule.save
        
        respond_to do |format|
          format.html { redirect_to new_schedule_path(future_schedule_id: @future_schedule.id), notice: "Pending schedule was successfully created." }
        end
        return
      elsif params[:commit].try(:downcase) == "update pending schedule"
        @future_schedule = FutureSchedule.find(params[:future_schedule_id])
        unless @future_schedule.nil?
          @future_schedule.from_date = from_date
          @future_schedule.to_date = to_date
          @future_schedule.from_time = @schedule.from_time
          @future_schedule.to_time = @schedule.to_time
          @future_schedule.job_id = @schedule.job_id
          @future_schedule.save
        end
        respond_to do |format|
          format.html { redirect_to new_schedule_path(future_schedule_id: @future_schedule.id), notice: "Pending schedule was successfully updated." }
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
        ActiveRecord::Base.transaction do
          (from_date..to_date).to_a.each do |schedule_date|
            params[:user_ids].try(:each) do |user_id, name|
              begin
                @schedule = Schedule.create(schedule_params.merge(user_id: user_id, schedule_date: schedule_date))
              rescue => e
                raise ActiveRecord::Rollback
              end
            end
          end
        end
      end
    end
    
    respond_to do |format|
      if @schedule.valid?
        if (!from_date.nil? && !to_date.nil?) && (to_date >= from_date)
          params[:user_ids].try(:each) do |user_id, name|
            user = User.find(user_id)
            ScheduleMailer.schedule_created(user, from_date, to_date, schedule_params).deliver
          end
        end
        
        format.html { redirect_to params[:return_path] || @schedule, notice: 'Schedule(s) was successfully created.' }
        format.json { render json: @schedule, status: :created, location: @schedule }
      else
        format.html { render action: "new" }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @schedule = Schedule.find(params[:id])

    respond_to do |format|
      if @schedule.update_attributes(schedule_params)
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
    schedules = Schedule.where(job_id: params[:job_id], schedule_date: Date.parse(params[:schedule_date]))
    @job = Job.find(params[:job_id])
    @schedules = schedules.detect {|s| s.user_id == current_user.id } ? schedules : []
  end
  
  def schedule_conflicts
    @warnings = []
    @errors = []
    
    from_date = Date.parse(params[:schedule][:schedule_date]) rescue nil
    to_date = Date.parse(params[:schedule][:through_schedule_date]) rescue nil
    to_date = from_date if to_date.nil?
    
    schedule = Schedule.find(params[:schedule_id]) unless params[:schedule_id].blank?
    
    if !schedule.nil?
      schedule.schedule_date = schedule_params[:schedule_date]
      schedule.from_time = schedule_params[:from_time]
      schedule.to_time = schedule_params[:to_time]
      
      check_schedule_for_conflicts([schedule])
    else
      unless from_date.nil? || to_date.nil?
        employee_ids = params[:user_ids].map {|k, v| k } rescue []
        employee_ids.each do |employee_id|
          schedules = []
          (from_date..to_date).to_a.each do |schedule_date|
            schedules << Schedule.new(schedule_params.merge(
              user_id: employee_id, 
              schedule_date: schedule_date, 
              from_time: fmt_time(:from_time, schedule_date.strftime("%m/%d/%Y")), 
              to_time: fmt_time(:to_time, schedule_date.strftime("%m/%d/%Y")))
            )
          end
          check_schedule_for_conflicts(schedules)
        end
      end
    end

    render layout: false
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
    
    query = FutureSchedule.where(["from_date >= ? OR from_date <= ?", Time.at(params[:start].to_i), Time.at(params[:end].to_i)])
    query = query.where(["to_date >= ? OR to_date <= ?", Time.at(params[:start].to_i), Time.at(params[:start].to_i)])
    query.each do |result|
      if job_color[result.job_id].nil?
        job_color[result.job_id] = color_index
        color_index += 1
        color_index = 0 if color_index >= colors.length
      end
      
      return_params = params.reject {|k, v| k == "format" }
      
      @schedules << result.to_schedule_event(colors[job_color[result.job_id]], new_schedule_path(future_schedule_id: result.id, return_path: schedules_path(return_params)))
      
    end
    
    query = Schedule.select(:job_id, :schedule_date).includes(job: [:customer]).group(:job_id, :schedule_date).order(job_id: :asc)
    query = query.where(["schedule_date >= ? AND schedule_date <= ?", Time.at(params[:start].to_i), Time.at(params[:end].to_i)])
    
    url_params = params.reject {|k, v| ["format"].include?(k) }
    
    query.each do |result|
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
  def schedules_conflict?(schedule_a, schedule_b)
    (schedule_a.from_time - schedule_b.to_time) * (schedule_b.from_time - schedule_a.to_time) >= 0
  end
  
  def check_schedule_for_conflicts(schedules)
    schedule = schedules.first
    hours = (schedule.to_time - schedule.from_time) / 3600.0 * schedules.count
    
    query = Schedule.where([
      "schedule_date >= ? AND schedule_date <= ? and user_id = ?", 
      schedule.schedule_date.beginning_of_week, 
      schedule.schedule_date.end_of_week, 
      schedule.user_id])
      
    if schedule.persisted?
      query = query.where(["id != ?", schedule.id])
    end
    
    query.each do |s|
      schedules.each do |t|
        if schedules_conflict?(t, s)
          @errors << "<strong>#{t.user.full_name}</strong>: The schedule conflicts with another schedule: <a href=\"#{schedule_path(s)}\">#{s.job.name}</a>".html_safe
        end
      end
      hours += s.hours
    end

    if hours >= 40
      @warnings << "Including this schedule, <strong>#{schedule.user.full_name}</strong> is scheduled for #{hours} hours during the week".html_safe
    end
  end
  
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
  
  def schedule_params
    if @schedule_params.nil?
      params[:schedule][:from_time] = fmt_time(:from_time, params[:schedule][:schedule_date])
      params[:schedule][:to_time] = fmt_time(:to_time, params[:schedule][:schedule_date])
      @schedule_params = params.require(:schedule).permit(:job_id, :schedule_date, :from_time, :to_time)
    end
    @schedule_params
  end
  
  def fmt_time(key, date)
    "#{date} #{params[:schedule][key]}"
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

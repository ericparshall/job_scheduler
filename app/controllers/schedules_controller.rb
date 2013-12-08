class SchedulesController < ApplicationController
  before_filter :require_admin_user, except: [ :scheduled_for_job ]
  before_filter :initialize_collections

  def index
    @from_date = (Date.parse(params[:from_date]) rescue nil) || Date.today.beginning_of_month
    @to_date = (Date.parse(params[:to_date]) rescue nil) || Date.today.end_of_month
    params[:unit] = "month"
    @schedules_grid = schedules_grid
    @schedules_grid.build

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def search
    Date.beginning_of_week = :sunday
    @from_date = (Date.parse(params[:from_date]) rescue nil) || Date.today.beginning_of_month
    @to_date = (Date.parse(params[:to_date]) rescue nil) || Date.today.end_of_month
    update_date_range
    
    @schedules = schedule_query.sort_by(&:schedule_date)
    @schedules_grid = schedules_grid
    @schedules_grid.build
    
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
    @schedule = Schedule.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @schedule }
    end
  end

  def edit
    @schedule = Schedule.find(params[:id])
  end

  def create
    @schedule = Schedule.new(schedule_params)
    params[:user_ids].try(:each) do |user_id, name|
      begin
        ActiveRecord::Base.transaction do
          @schedule = Schedule.create(schedule_params.merge(user_id: user_id))
        end
      rescue => e
        break
      end
    end

    respond_to do |format|
      if @schedule.valid?
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
    @schedules = schedules.detect {|s| s.user_id == current_user.id } ? schedules : []
  end
  
  private
  def initialize_collections
    @users = User.all.sort_by{|u| u.full_name }.collect {|u| [u.full_name, u.id] }
    @jobs = Job.all.sort_by{|j| j.name }.collect {|j| [j.name, j.id] }
  end
  
  def schedules_grid
    PivotTable::Grid.new {|g| g.source_data = schedules_data; g.column_name = :job_id; g.row_name = :user_id; g.value_name = :hours }
  end
  
  def schedules_data
    schedule_query.select("job_id, user_id, sum(hours) as hours").group("job_id, user_id").map {|s| OpenStruct.new(job_id: s.job_id, user_id: s.user_id, hours: s.hours) }
  end
  
  def schedule_query
    schedule_query = Schedule.where(["schedule_date >= ? and schedule_date <= ?", @from_date, @to_date]).includes(:user, :job)
    schedule_query = schedule_query.where(job_id: params[:job_id]) unless params[:job_id].blank?
    schedule_query = schedule_query.where(user_id: params[:user_id]) unless params[:user_id].blank?
    schedule_query
  end
  
  def schedule_params
    params[:from_time] = "#{params[:schedule_date]} #{params[:from_time]}"
    params[:to_time] = "#{params[:schedule_date]} #{params[:to_time]}"
    params.require(:schedule).permit(:job_id, :schedule_date, :from_time, :to_time)
  end
  
  def update_date_range
    case params[:unit]
    when "today"
      @from_date = Date.today
      @to_date = Date.today
    when "month"
      @from_date = @from_date.beginning_of_month
      @to_date = @from_date.end_of_month
    when "week"
      @from_date = @from_date.beginning_of_week
      @to_date = @from_date.end_of_week
    when "day"
      @to_date = @from_date
    else
      params[:unit] = "day" if @from_date == @to_date
      params[:unit] = "month" if @from_date == @from_date.beginning_of_month && @to_date == @from_date.end_of_month
      params[:unit] = "week" if @from_date == @from_date.beginning_of_week && @to_date == @from_date.end_of_week
      params[:unit] = "today" if @from_date == Date.today && @to_date == Date.today
    end
  end
end

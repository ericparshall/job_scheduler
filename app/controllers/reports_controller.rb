class ReportsController < ApplicationController
  before_filter :require_admin_user
  layout "application_angular"
  
  def index
    
  end
  
  def weeks_by_beginning 
    @weeks = []
    
    (-55..55).to_a.each do |i|
      @weeks << (Time.now.beginning_of_week + (7 * i).days).strftime("%F")
    end
    
    @weeks.sort!
    
    respond_to do |format|
      format.json { render json: @weeks }
    end
  end
  
  def employees_scheduled_unschedule
    from_time = Time.parse("#{params[:fromDate]} 00:00:00 UTC") rescue nil
    to_time = Time.parse("#{params[:toDate]} 11:59:59 UTC") rescue nil
    
    @users = User.find_by_sql([%Q(SELECT distinct users.id as id,
    users.full_name as "full_name",
    users.email as "email",
    users.rating as rating,
    manager.full_name as "manager_name",
    user_types.name as "user_type_name",
    case when schedules.id is null then false else true end as scheduled 
    FROM "users" 
    LEFT JOIN schedules on users.id = schedules.user_id 
      AND ((from_time >= ? and from_time <= ?) or (to_time >= ? and to_time <= ?))
    LEFT JOIN user_types on user_types.id = users.user_type_id 
    LEFT JOIN users as manager on manager.id = users.manager_id 
    WHERE "users"."archived" = ?), from_time, to_time, from_time, to_time, false])

    @users.each do |u|
      u.url = employee_url(u.id)
    end
    
    @fields = {
      full_name: "Full Name",
      email: "Email",
      rating: "Rating",
      manager_name: "Manager",
      user_type_name: "User Type",
      scheduled: "Is Scheduled?"
    }
    
    @results = {
      fields: @fields,
      records: @users
    }
    
    respond_to do |format|
      format.json { 
        render json: @results.to_json(methods: :url)
      }
    end
  end
  
  def scheduled_for_the_week
    from_time = Time.parse("#{params[:selectedWeek]} 00:00:00 UTC") rescue nil
    to_time = from_time.try(:end_of_week)
    
    @schedules = Schedule.select(%Q(schedules.id as id, 
    users.full_name as employee_name, 
    jobs.name as job_name,
    customers.name as customer_name,
    from_time,
    to_time
    )).joins({ user: {}, job: { customer: {} } }).
    where(["(from_time >= ? and from_time <= ?) or (to_time >= ? and to_time <= ?)", from_time, to_time, from_time, to_time])
    
    @schedules.each do |s|
      s.url = schedule_url(s.id)
    end
    
    @fields = {
      employee_name: "Employee Name",
      job_name: "Job",
      customer_name: "Customer",
      from_time: "From Time",
      to_time: "To Time"
    }
    
    @results = {
      fields: @fields,
      records: @schedules
    }
    
    respond_to do |format|
      format.json { render json: @results.to_json(methods: :url) }
    end
  end
end

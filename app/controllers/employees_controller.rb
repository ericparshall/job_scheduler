class EmployeesController < ApplicationController
  skip_before_filter :require_no_authentication
  before_filter :require_admin_user
  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to employee_path(@user), notice: 'Employee was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html { redirect_to employee_path(@user), notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to employees_url }
      format.json { head :no_content }
    end
  end
  
  def schedule
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
    
    query = Schedule.where(user_id: params[:employee_id])
    query = query.where(["schedule_date >= ?", Time.at(params[:start].to_i)]) unless params[:start].blank?
    query = query.where(["schedule_date <= ?", Time.at(params[:end].to_i)]) unless params[:end].blank?
    
    job_ids = query.map &:job_id
    job_color = {}
    color_index = 0
    job_ids.each do |job_id|
      job_color[job_id] = colors[color_index]
      color_index += 1
      color_index = 0 if color_index >= colors.length
    end
    
    query.each do |schedule|
      @schedules << schedule.to_schedule_event(job_color[schedule.job_id], edit_schedule_path(schedule, return_path: return_path))
    end
    
    respond_to do |format|
      format.json { render json: @schedules}
    end
  end
  
  def employee_list
    list = User.all.sort_by{|u| u.full_name }
    matches = Set.new
    list.find_all {|l| l.full_name =~ /^#{params[:term]}/i }.each {|l| matches << l }
    list.find_all {|l| l.full_name =~ /#{params[:term]}/i }.each {|l| matches << l }
    
    respond_to do |format|
      format.json { render json: matches.collect {|u| { value: u.full_name, id: u.id } } }
    end
  end
  
  private
  def user_params
    params[:user].delete_if {|k, v| [ "password", "password_confirmation" ].include?(k) && v.blank? }
    params.require(:user).permit(:full_name, :email, :password, :password_confirmation, :user_type_id, :manager_id, :phone_number, :address)
  end
  
  def return_path
    employee_path(User.find(params[:employee_id]))
  end
end

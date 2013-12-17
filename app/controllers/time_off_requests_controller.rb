class TimeOffRequestsController < ApplicationController
  before_filter :require_admin_user, only: [ :approve ]
  before_action :set_time_off_request, only: [:show, :edit, :update, :destroy, :approve]
  before_filter :filter_time_off_requests, only: [:index]

  # GET /time_off_requests
  def index
    
  end

  # GET /time_off_requests/1
  def show
  end

  # GET /time_off_requests/new
  def new
    @time_off_request = TimeOffRequest.new(manager_id: current_user.manager_id, user_id: current_user.id)
  end

  # GET /time_off_requests/1/edit
  def edit
  end

  # POST /time_off_requests
  def create
    manager_id = current_user.user_type.manager? ? params[:time_off_request][:manager_id] : current_user.manager_id
    user_id = current_user.user_type.manager? ? params[:time_off_request][:user_id] : current_user.id
    @time_off_request = TimeOffRequest.new(time_off_request_params.merge(manager_id: manager_id, user_id: user_id))

    if @time_off_request.save
      redirect_to @time_off_request, notice: 'Time off request was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /time_off_requests/1
  def update
    if @time_off_request.update(time_off_request_params)
      redirect_to @time_off_request, notice: 'Time off request was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /time_off_requests/1
  def destroy
    @time_off_request.destroy
    redirect_to time_off_requests_url, notice: 'Time off request was successfully destroyed.'
  end
  
  def approve
    @time_off_request.approve
    redirect_to time_off_requests_url, notice: 'Time off request has been approved.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_time_off_request
      @time_off_request = TimeOffRequest.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def time_off_request_params
      params.require(:time_off_request).permit(:day_off_requested, :comment)
    end
    
    def filter_time_off_requests
      @time_off_requests = TimeOffRequest.joins(:status).where(["user_id = ? or (manager_id = ? and time_off_request_statuses.name = 'Requested')", current_user.id, current_user.id])
    end
end

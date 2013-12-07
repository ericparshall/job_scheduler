class TimeOffRequestsController < ApplicationController
  before_action :set_time_off_request, only: [:show, :edit, :update, :destroy]
  before_filter :filter_

  # GET /time_off_requests
  def index
    @time_off_requests = TimeOffRequest.all
  end

  # GET /time_off_requests/1
  def show
  end

  # GET /time_off_requests/new
  def new
    @time_off_request = TimeOffRequest.new
  end

  # GET /time_off_requests/1/edit
  def edit
  end

  # POST /time_off_requests
  def create
    @time_off_request = TimeOffRequest.new(time_off_request_params.merge)

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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_time_off_request
      @time_off_request = TimeOffRequest.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def time_off_request_params
      params.require(:time_off_request).permit(:day_off_requested, :comment)
    end
end

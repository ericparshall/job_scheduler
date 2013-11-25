class HomeController < ApplicationController
  def index
    
  end
  
  def my_schedule
    @schedules = []
    
    query = Schedule.where(user_id: current_user.id)
    query = query.where(["schedule_date >= ?", Time.at(params[:start].to_i)]) unless params[:start].blank?
    query = query.where(["schedule_date <= ?", Time.at(params[:end].to_i)]) unless params[:end].blank?
    query.each do |schedule|
      @schedules << schedule.to_schedule_event
    end
    
    respond_to do |format|
      format.json { render json: @schedules}
    end
  end
end

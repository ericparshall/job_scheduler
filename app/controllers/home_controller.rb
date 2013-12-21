class HomeController < ApplicationController
  def index
    
  end
  
  def my_schedule
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
    
    query = Schedule.where(user_id: current_user.id)
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
      @schedules << schedule.to_schedule_event(job_color[schedule.job_id])
    end
    
    respond_to do |format|
      format.json { render json: @schedules}
    end
  end
end

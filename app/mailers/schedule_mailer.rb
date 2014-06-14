class ScheduleMailer < ActionMailer::Base
  default from: "eric@parshall.us"
  
  def schedule_created(user, from_date, to_date, schedule_params)
    @user = user
    @schedule_params = schedule_params
    @schedule_noun = from_date == to_date ? "A schedule has" : "Schedules have"
    @from_date = from_date
    @to_date = to_date
    @from_time = schedule_params[:from_time]
    @to_time = schedule_params[:to_time]
    @job = Job.find(schedule_params[:job_id])
    mail(to: @user.email, subject: "Schedule created")
  end
end
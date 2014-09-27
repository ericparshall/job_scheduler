class ScheduleMailer < ActionMailer::Base
  
  def schedule_created(user_id, job_id, schedule_blocks)
    @user = User.find(user_id)
    @schedule_blocks = schedule_blocks
    @schedule_noun = schedule_blocks.size == 1 ? "A schedule has" : "Schedules have"
    @job = Job.find(job_id)
    mail(to: @user.email, subject: "Schedule created")
  end
end
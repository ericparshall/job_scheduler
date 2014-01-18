class TimeOffMailer < ActionMailer::Base
  default from: "eric@parshall.us"
  
  def time_off_request(user, manager, time_off_request)
    @employee = user
    @manager = manager
    @time_off_request = time_off_request
    
    mail(to: @manager.email, subject: "Time off requested")
  end
end

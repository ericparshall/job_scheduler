class TimeOffMailer < ActionMailer::Base
  default from: "eric@parshall.us"
  
  def time_off_request(user, manager, time_off_request)
    @employee = user
    @manager = manager
    @time_off_request = time_off_request
    
    mail(to: @manager.email, subject: "Time off requested")
  end
  
  def time_off_approved(time_off_request)
    @employee = time_off_request.user
    @manager = time_off_request.manager
    @time_off_request = time_off_request
    mail(to: @employee.email, subject: "Time off request approved")
  end
  
  def time_off_denied(time_off_request)
    @employee = time_off_request.user
    @manager = time_off_request.manager
    @time_off_request = time_off_request
    mail(to: @employee.email, subject: "Time off request denied")
  end
end

class TimeOffMailer < ActionMailer::Base
  default from: "eric@parshall.us"
  
  def time_off_request(user, time_off_request)
    @employee = user
    @time_off_request = time_off_request
    
    manager_type_ids = UserType.where(manager: true).map(&:id)
    User.all.where(user_type_id: manager_type_ids).each do |manager|
      @manager = manager
      mail(to: manager.email, subject: "Time off requested")
    end
  end
end

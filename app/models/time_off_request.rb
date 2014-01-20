class TimeOffRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :manager, class_name: "User", foreign_key: "manager_id"
  belongs_to :status, class_name: "TimeOffRequestStatus", foreign_key: "status_id"
  
  validates :day_off_requested, :user_id, presence: true
  
  before_save do
    self.status ||= TimeOffRequestStatus.where(name: "Requested").first
  end
  
  def approve(manager)
    self.status = TimeOffRequestStatus.where(name: "Approved").first
    self.manager = manager
    self.save
    
    job = Job.find_or_create_by(name: "Time Off")
    from_time = Time.utc(self.day_off_requested.year, self.day_off_requested.month, self.day_off_requested.day, 9)
    to_time = Time.utc(self.day_off_requested.year, self.day_off_requested.month, self.day_off_requested.day, 17)
    Schedule.create(
      job_id: job.id, 
      user_id: self.user_id, 
      hours: 8, 
      schedule_date: self.day_off_requested, 
      from_time: from_time,
      to_time: to_time)
  end
end

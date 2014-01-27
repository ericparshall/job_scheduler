class TimeOffRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :manager, class_name: "User", foreign_key: "manager_id"
  belongs_to :status, class_name: "TimeOffRequestStatus", foreign_key: "status_id"
  
  validates :from_date, :to_date, :user_id, presence: true
  
  before_save do
    self.status ||= TimeOffRequestStatus.where(name: "Requested").first
  end
  
  def approve(manager)
    self.status = TimeOffRequestStatus.where(name: "Approved").first
    self.manager = manager
    self.save
    
    (from_date..to_date).to_a.each do |schedule_date|
      job = Job.find_or_create_by(name: "Time Off")
      from_time = Time.utc(self.from_date.year, self.from_date.month, self.from_date.day, 9)
      to_time = Time.utc(self.to_date.year, self.to_date.month, self.to_date.day, 17)
      Schedule.create(
        job_id: job.id, 
        user_id: self.user_id, 
        hours: 8, 
        schedule_date: schedule_date, 
        from_time: from_time,
        to_time: to_time
      )
    end
  end
  
  def deny(manager)
    self.status = TimeOffRequestStatus.where(name: "Denied").first
    self.manager = manager
    self.save
  end
end

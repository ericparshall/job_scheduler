class Schedule < ActiveRecord::Base
  belongs_to :user
  belongs_to :job
  
  validates :schedule_date, :from_time, :to_time, :job_id, :user_id, presence: true
  validate :hours_greater_than_zero
  
  before_validation do
    unless self.schedule_date.nil?
      unless self.from_time.nil?
        self.from_time = "#{self.schedule_date.strftime("%m/%d/%Y")} #{self.from_time.strftime("%I:%M%P")}"
      end
      unless self.to_time.nil?
        self.to_time = "#{self.schedule_date.strftime("%m/%d/%Y")} #{self.to_time.strftime("%I:%M%P")}"
      end
    end
    self.hours = (self.to_time - self.from_time) / 3600.0 rescue nil
  end
  
  def to_schedule_event(color, link_to_url = nil)
    event = {
      borderColor: "black",
      textColor: "black",
      backgroundColor: color,
      title: "#{!self.job.customer.nil? ? self.job.customer.name + ": " : ""}#{self.job.name}, #{self.hours} hrs",
      start: "#{self.schedule_date.strftime("%Y-%m-%d")} #{self.from_time.strftime("%H:%M:%S")}",
      end: "#{self.schedule_date.strftime("%Y-%m-%d")} #{self.to_time.strftime("%H:%M:%S")}",
      schedule_date: self.schedule_date.strftime("%Y-%m-%d"),
      job_id: self.job_id,
      allDay: false
    }
    event[:url] = link_to_url if link_to_url
    event
  end
  
  private
  def hours_greater_than_zero
    errors.add(:to_time, "must be greater than From time") if self.hours.nil? || self.hours < 0
  end
end

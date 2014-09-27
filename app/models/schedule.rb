class Schedule < ActiveRecord::Base
  belongs_to :user
  belongs_to :job
  
  validates :from_time, :to_time, :job_id, :user_id, presence: true
  before_validation { self.hours = (self.to_time - self.from_time) / 3600.0 rescue nil }
  validate :hours_greater_than_zero

  def to_schedule_event(color, link_to_url = nil)
    event = {
      borderColor: "black",
      textColor: "black",
      backgroundColor: color,
      title: "#{!self.job.customer.nil? ? self.job.customer.name + ": " : ""}#{self.job.name}, #{self.hours} hrs",
      start: "#{self.from_time.strftime("%Y-%m-%d")} #{self.from_time.strftime("%H:%M:%S")}",
      end: "#{self.to_time.strftime("%Y-%m-%d")} #{self.to_time.strftime("%H:%M:%S")}",
      schedule_date: self.from_time.strftime("%Y-%m-%d"),
      job_id: self.job_id,
      allDay: false
    }
    event[:url] = link_to_url if link_to_url
    event
  end
  
  def to_schedule_event_grouped_by_job_id(color, link_to_url = nil)
    event = {
      borderColor: "black",
      textColor: "black",
      backgroundColor: color,
      title: "#{!self.job.customer.nil? ? self.job.customer.name + ": " : ""}#{self.job.name}",
      start: "#{self.from_time.strftime("%Y-%m-%d")}",
      allDay: true,
      schedule_date: self.from_time.strftime("%Y-%m-%d"),
      job_id: self.job_id
    }
    event[:url] = link_to_url if link_to_url
    event
  end
  
  private
  def hours_greater_than_zero
    errors.add(:to_time, "must be greater than From time") if self.hours.nil? || self.hours < 0
  end
end

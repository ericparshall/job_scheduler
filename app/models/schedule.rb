class Schedule < ActiveRecord::Base
  belongs_to :user
  belongs_to :job
  
  validates :schedule_date, :from_time, :to_time, presence: true
  validate :hours_greater_than_zero
  
  before_validation do
    #self.from_time = Time.new(self.schedule_date.year, self.schedule_date.month, self.schedule_date.day, self.from_time.hour, self.from_time.min) unless self.from_time.nil?
    #self.to_time = Time.new(self.schedule_date.year, self.schedule_date.month, self.schedule_date.day, self.to_time.hour, self.to_time.min) unless self.to_time.nil?
    self.hours = (self.to_time - self.from_time) / 3600.0 rescue nil
  end
  
  def to_schedule_event(link_to_url = nil)
    event = {
      title: "#{self.job.name}, #{self.hours} hrs",
      start: "#{self.schedule_date.strftime("%Y-%m-%d")} #{self.from_time.strftime("%H:%M:%S")}",
      end: "#{self.schedule_date.strftime("%Y-%m-%d")} #{self.to_time.strftime("%H:%M:%S")}",
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

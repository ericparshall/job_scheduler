class FutureSchedule < ActiveRecord::Base
  belongs_to :job  
  validates :job_id, presence: true
  
  def validate(record)
    unless record.from_time <= record.to_time
      errors[:to_time] << "To Date/Time must be greater than From Date/Time"
    end
    unless record.through_date >= record.from_time.to_date
      errors[:through_date] << "Repeat Through date must be equal to or greater than the From Date"
    end
  end
  
  def to_schedule_event(color, link_to_url = nil)
    event = {
      borderColor: "black",
      textColor: "black",
      backgroundColor: color,
      title: "#{!self.job.try(:customer).nil? ? self.job.customer.name + ": " : ""}#{self.job.try(:name)}",
      start: "#{self.from_date.strftime("%Y-%m-%d")} #{self.from_time.strftime("%H:%M:%S")}",
      end: "#{self.to_date.strftime("%Y-%m-%d")} #{self.to_time.strftime("%H:%M:%S")}",
      future_schedule_id: self.id,
      allDay: true
    }
    event[:url] = link_to_url if link_to_url
    event
  end
end

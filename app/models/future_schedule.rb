class FutureSchedule < ActiveRecord::Base
  belongs_to :job
  before_validation do
    self.from_time = "#{self.from_date.strftime("%m/%d/%Y")} #{self.from_time.strftime("%I:%M%P")}" rescue nil
    self.to_time = "#{self.to_date.strftime("%m/%d/%Y")} #{self.to_time.strftime("%I:%M%P")}"
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

class Schedule < ActiveRecord::Base
  belongs_to :user
  belongs_to :job
  
  validates :schedule_date, :from_time, :to_time, presence: true
  validate :hours_greater_than_zero
  
  before_validation do
    self.hours = (self.to_time - self.from_time) / 3600.0 rescue nil
  end
  
  private
  def hours_greater_than_zero
    errors.add(:to_time, "Time range must be positive") if self.hours.nil? || self.hours < 0
  end
end

class Job < ActiveRecord::Base
  has_many :schedules
end

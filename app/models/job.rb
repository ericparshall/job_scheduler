class Job < ActiveRecord::Base
  has_many :schedules
  has_many :skills
end

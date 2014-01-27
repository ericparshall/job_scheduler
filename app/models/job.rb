class Job < ActiveRecord::Base
  has_many :schedules
  has_many :skills
  belongs_to :customer
  belongs_to :point_of_contact
end

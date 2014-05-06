class Job < ActiveRecord::Base
  has_many :schedules
  has_many :skills
  belongs_to :customer
  belongs_to :point_of_contact
  belongs_to :internal_point_of_contact, class_name: "User"
end

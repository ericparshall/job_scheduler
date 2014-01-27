class Customer < ActiveRecord::Base
  has_many :point_of_contacts
  has_many :jobs
end

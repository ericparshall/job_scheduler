class PointOfContact < ActiveRecord::Base
  belongs_to :customer
  has_many :jobs
end

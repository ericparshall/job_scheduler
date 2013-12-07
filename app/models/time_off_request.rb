class TimeOffRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :manager, class_name: "User", foreign_key: "manager_id"
end

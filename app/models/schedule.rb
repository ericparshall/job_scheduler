class Schedule < ActiveRecord::Base
  attr_accessible :hours, :job_id, :schedule_date, :user_id
  belongs_to :user
  belongs_to :job
end

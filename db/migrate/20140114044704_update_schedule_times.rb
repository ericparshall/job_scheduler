class UpdateScheduleTimes < ActiveRecord::Migration
  def up
    Schedule.all.each do |s|
      s.from_time = "#{s.schedule_date} #{s.from_time}"
      s.to_time = "#{s.schedule_date} #{s.to_time}"
      s.save
    end
  end
  
  def down
    
  end
end

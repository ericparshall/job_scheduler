class UpdateThroughDateOnFutureSchedules < ActiveRecord::Migration
  def up
    FutureSchedule.all.each do |future_schedule|
      future_schedule.from_time = "#{future_schedule.from_date.strftime("%Y-%m-%d")} #{future_schedule.from_time.strftime("%H:%M:%S")}"
      future_schedule.to_time = "#{future_schedule.from_date.strftime("%Y-%m-%d")} #{future_schedule.to_time.strftime("%H:%M:%S")}"
      future_schedule.through_date = future_schedule.to_date
      future_schedule.to_date = future_schedule.from_date
      future_schedule.save
    end
  end
  
  def down
    
  end
end

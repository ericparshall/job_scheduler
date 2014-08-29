class EnsureDatesCorrect < ActiveRecord::Migration
  def change
    Schedule.all.each do |s|
      unless s.schedule_date.nil?
        unless s.from_time.nil?
          s.from_time = "#{s.schedule_date.strftime("%m/%d/%Y")} #{s.from_time.strftime("%I:%M%P")}"
        end
        unless s.to_time.nil?
          s.to_time = "#{s.schedule_date.strftime("%m/%d/%Y")} #{s.to_time.strftime("%I:%M%P")}"
        end
      end
      
      s.save
    end
  end
end

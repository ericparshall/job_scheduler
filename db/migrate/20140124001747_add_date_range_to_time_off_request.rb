class AddDateRangeToTimeOffRequest < ActiveRecord::Migration
  def change
    change_table :time_off_requests do |t|
      t.date :to_date
      t.rename :day_off_requested, :from_date
    end
    
    TimeOffRequest.all.each {|tor| tor.to_date = tor.from_date; tor.save }
  end
end

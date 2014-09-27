class AddThroughDateToFutureSchedule < ActiveRecord::Migration
  def change
    change_table :future_schedules do |t|
      t.date :through_date
    end
  end
end

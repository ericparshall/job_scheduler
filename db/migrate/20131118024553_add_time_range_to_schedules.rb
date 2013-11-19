class AddTimeRangeToSchedules < ActiveRecord::Migration
  def up
    change_table :schedules do |t|
      t.datetime :from_time
      t.datetime :to_time
    end
  end
  
  def down
    change_table :schedules do |t|
      t.remove :from_time
      t.remove :to_time
    end
  end
end

class AddIndexToScheduleDate < ActiveRecord::Migration
  def up
    add_index :schedules, [:user_id, :schedule_date]
  end
  
  def down
    remove_index :schedules, [:user_id, :schedule_date]
  end
end

class AddTimeRangeIndexToSchedules < ActiveRecord::Migration
  def change
    add_index :schedules, [:user_id, :from_time, :to_time]
  end
end

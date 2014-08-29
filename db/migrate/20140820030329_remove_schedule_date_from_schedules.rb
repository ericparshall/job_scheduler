class RemoveScheduleDateFromSchedules < ActiveRecord::Migration
  def up
    change_table :schedules do |t|
      t.remove :schedule_date
    end
  end
  
  def down
    change_table :schedules do |t|
      t.date :schedule_date
    end
  end
end

class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.integer :job_id
      t.integer :user_id
      t.decimal :hours
      t.date :schedule_date

      t.timestamps
    end
  end
end

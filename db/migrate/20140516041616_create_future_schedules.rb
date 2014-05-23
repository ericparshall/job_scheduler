class CreateFutureSchedules < ActiveRecord::Migration
  def change
    create_table :future_schedules do |t|
      t.integer :job_id
      t.date :from_date
      t.date :to_date
      t.datetime :from_time
      t.datetime :to_time

      t.timestamps
    end
  end
end

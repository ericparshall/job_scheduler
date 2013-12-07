class CreateTimeOffRequests < ActiveRecord::Migration
  def change
    create_table :time_off_requests do |t|
      t.integer :user_id
      t.integer :manager_id
      t.date :day_off_requested
      t.text :comment

      t.timestamps
    end
  end
end

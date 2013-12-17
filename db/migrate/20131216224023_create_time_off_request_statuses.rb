class CreateTimeOffRequestStatuses < ActiveRecord::Migration
  def change
    create_table :time_off_request_statuses do |t|
      t.string :name

      t.timestamps
    end
    
    change_table :time_off_requests do |t|
      t.integer :status_id
    end
  end
end

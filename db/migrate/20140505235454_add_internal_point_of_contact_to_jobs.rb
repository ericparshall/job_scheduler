class AddInternalPointOfContactToJobs < ActiveRecord::Migration
  def change
    change_table :jobs do |t|
      t.integer :internal_point_of_contact_id
    end
  end
end

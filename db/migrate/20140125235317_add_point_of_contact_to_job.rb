class AddPointOfContactToJob < ActiveRecord::Migration
  def change
    change_table :jobs do |t|
      t.integer :customer_id
      t.integer :point_of_contact_id
      t.remove :point_of_contact
      t.remove :phone_number
      t.remove :email_address
      t.remove :address
    end
  end
end

class AddAttributesToJob < ActiveRecord::Migration
  def change
    change_table :jobs do |t|
      t.string :point_of_contact
      t.string :phone_number
      t.string :email_address
      t.text :address
    end
  end
end

class CreatePointOfContacts < ActiveRecord::Migration
  def change
    create_table :point_of_contacts do |t|
      t.integer :customer_id
      t.string :name
      t.string :address
      t.string :phone_number
      t.string :email_address
      t.boolean :archived, default: false

      t.timestamps
    end
  end
end

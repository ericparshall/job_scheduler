class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :name
      t.string :point_of_contact
      t.string :address
      t.string :phone_number
      t.string :email_address
      t.boolean :archived, default: false

      t.timestamps
    end
  end
end

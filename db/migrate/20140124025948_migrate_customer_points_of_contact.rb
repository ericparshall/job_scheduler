class MigrateCustomerPointsOfContact < ActiveRecord::Migration
  def up
    Customer.all.each do |customer|
      customer.point_of_contacts.create(
        name: customer.point_of_contact,
        address: customer.address,
        phone_number: customer.phone_number,
        email_address: customer.email_address
      )
    end
    
    change_table :customers do |t|
      t.remove :point_of_contact
      t.remove :address
      t.remove :phone_number
      t.remove :email_address
    end
  end
  
  def down
    change_table :customers do |t|
      t.string :point_of_contact
      t.string :address
      t.string :phone_number
      t.string :email_address
    end
    
    Customer.all.each do |customer|
      poc = customer.point_of_contacts.first
      unless poc.nil?
        customer.point_of_contact = poc.name
        customer.address = poc.address
        customer.phone_number = poc.phone_number
        customer.email_address = poc.email_address
        customer.save
      end
    end
  end
end

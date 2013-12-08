class AddAttributesToUser < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.string :phone_number
      t.string :address
    end
  end
  
  def down
    change_table :users do |t|
      t.remove :phone_number, :address
    end
  end
end

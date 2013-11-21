class AddManagerId < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.integer :manager_id
    end
    add_index :users, :manager_id
  end
  
  def down
    change_table :users do |t|
      t.remove :manager_id
    end
  end
end

class AddAdminToUser < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.boolean :admin, default: false
    end
  end
  
  def down
    change_table :users do |t|
      t.remove :admin
    end
  end
end

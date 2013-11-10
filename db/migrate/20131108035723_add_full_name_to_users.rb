class AddFullNameToUsers < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.string :full_name
    end
  end
  
  def down
    change_table :users do |t|
      t.remove :full_name
    end
  end
end

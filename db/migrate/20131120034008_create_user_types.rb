class CreateUserTypes < ActiveRecord::Migration
  def up
    create_table :user_types do |t|
      t.string :name
      t.boolean :admin
      t.boolean :manager
      t.timestamps
    end
    
    change_table :users do |t|
      t.integer :user_type_id
    end
  end
  
  def down
    drop_table :user_types
    change_table :users do |t|
      t.remove :user_type_id
    end
  end
end

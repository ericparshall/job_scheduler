class AddFirstIndexes < ActiveRecord::Migration
  def change
    add_index :users_skills, [:user_id, :skill_id]
    
  end
end

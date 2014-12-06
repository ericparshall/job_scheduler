class AddFirstIndexes < ActiveRecord::Migration
  def change
    add_index :users_skills, [:user_id, :skill_id]
    add_index :schedules, [:user_id]
  end
end

class CreateSkills < ActiveRecord::Migration
  def change
    create_table :skills do |t|
      t.string :name
      t.boolean :archived, default: false
      t.timestamps
    end
    
    create_table :users_skills, id: false do |t|
      t.integer :user_id
      t.integer :skill_id
    end
    
    create_table :jobs_skills, id: false do |t|
      t.integer :job_id
      t.integer :skill_id
    end
  end
end

class AddArchivedAttribute < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :archived, default: false
    end
    
    change_table :jobs do |t|
      t.boolean :archived, default: false
    end
  end
end

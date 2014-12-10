class IndexUsersArchived < ActiveRecord::Migration
  def change
    add_index :users, [:archived]
    add_index :customers, [:archived]
    add_index :jobs, [:archived]
  end
end

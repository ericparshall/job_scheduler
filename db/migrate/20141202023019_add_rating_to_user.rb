class AddRatingToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.integer :rating, default: 0
    end
  end
end

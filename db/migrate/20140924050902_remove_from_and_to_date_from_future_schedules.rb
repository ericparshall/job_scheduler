class RemoveFromAndToDateFromFutureSchedules < ActiveRecord::Migration
  def change
    change_table :future_schedules do |t|
      t.remove :from_date
      t.remove :to_date
    end
  end
end

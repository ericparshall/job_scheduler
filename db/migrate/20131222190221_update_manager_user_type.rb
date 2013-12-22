class UpdateManagerUserType < ActiveRecord::Migration
  def change
    UserType.where("name like '%Manager%'").first.update_attribute(:name, "Manager / Point-of-Contact")
  end
end

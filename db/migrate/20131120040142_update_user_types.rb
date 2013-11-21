class UpdateUserTypes < ActiveRecord::Migration
  def up
    employee = UserType.create(name: "Employee", admin: false, manager: false)
    UserType.create(name: "Manager", admin: false, manager: true)
    admin = UserType.create(name: "Admin", admin: true, manager: true)
    
    User.all.each do |u|
      u.update_attribute(:user_type_id, employee.id) unless u.admin?
      u.update_attribute(:user_type_id, admin.id) if u.admin?
    end
    
    change_table :users do |t|
      t.remove :admin
    end
  end
  
  def down
    change_table :users do |t|
      t.boolean :admin
    end
    
    admin = UserType.where(name: "Admin").first
    User.where(user_type_id: admin.id).each {|u| u.update_attribute(:admin, true) }
  end
end

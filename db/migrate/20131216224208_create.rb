class Create < ActiveRecord::Migration
  def change
    TimeOffRequestStatus.create(name: "Requested")
    TimeOffRequestStatus.create(name: "Approved")
    TimeOffRequestStatus.create(name: "Denied")
  end
end

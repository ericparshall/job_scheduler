require 'rails_helper'

RSpec.describe SchedulesController, :type => :controller do
  describe "#schedule_conflicts" do
    before :each do
      @users = []
      4.times { @users << Fabricate(:user) }
      @users_selected = @users.to_json
      signed_in_as_a_valid_user
    end
    
    it "should check for conflics for each user" do
      schedule = Fabricate.build(:schedule, 
        user_id: @users.first.id, 
        job_id: 1, 
        from_time: Time.parse("09/05/2014 1:00am UTC"),
        to_time: Time.parse("09/05/2014 6:00am UTC")
      )

      expect(controller).to receive(:get_schedule_blocks).and_return(
        [ { from_time: Time.parse("09/05/2014 1:00am UTC"), to_time: Time.parse("09/05/2014 6:00am UTC") } ]
      )
      expect(ScheduleConflictChecker).to receive(:check_schedule_for_conflicts).exactly(4).times.and_return({errors: [], warnings: []})
      get :schedule_conflicts, users_selected: @users_selected, schedule: schedule.to_json, format: :json
      conflicts = JSON.parse(response.body)
      expect(conflicts["errors"]).to eq([])
      expect(conflicts["warnings"]).to eq([])
    end
  end
  
  describe "#get_schedule_blocks" do
    it "should return a list for the range" do
      schedule_blocks = SchedulesController.new.get_schedule_blocks([{
        "$$hashKey" => "object:7",
        "from_time" => "2015-01-01T09:00:00.000Z",
        "through_date" => "2015-01-08T00:00:00.000Z",
        "to_time" => "2015-01-01T17:30:00.000Z"
      }])
      
      expect( schedule_blocks.size ).to eq(8)
      
      expect( schedule_blocks[0][:from_time].to_s ).to eq("2015-01-01 09:00:00 UTC")
      expect( schedule_blocks[0][:to_time].to_s ).to eq("2015-01-01 17:30:00 UTC")
      
      expect( schedule_blocks[7][:from_time].to_s ).to eq("2015-01-08 09:00:00 UTC")
      expect( schedule_blocks[7][:to_time].to_s ).to eq("2015-01-08 17:30:00 UTC")
    end
    
    it "should return a list matching the list passed in" do
      schedule_blocks = SchedulesController.new.get_schedule_blocks([
        {
          "$$hashKey" => "object:7",
          "from_time" => "2015-01-01T09:00:00.000Z",
          "through_date" => "2015-01-08T00:00:00.000Z",
          "to_time" => "2015-01-01T17:30:00.000Z"
        },
        {
          "$$hashKey" => "object:8",
          "from_time" => "2015-01-03T11:15:00.000Z",
          "to_time" => "2015-01-03T15:30:00.000Z"
        },
        {
          "$$hashKey" => "object:9",
          "from_time" => "2015-01-06T01:12:00.000Z",
          "to_time" => "2015-01-06T14:45:00.000Z"
        }
      ])
      
      expect( schedule_blocks.size ).to eq(3)
      
      expect( schedule_blocks[0][:from_time].to_s ).to eq("2015-01-01 09:00:00 UTC")
      expect( schedule_blocks[0][:to_time].to_s ).to eq("2015-01-01 17:30:00 UTC")
      
      expect( schedule_blocks[1][:from_time].to_s ).to eq("2015-01-03 11:15:00 UTC")
      expect( schedule_blocks[1][:to_time].to_s ).to eq("2015-01-03 15:30:00 UTC")
      
      expect( schedule_blocks[2][:from_time].to_s ).to eq("2015-01-06 01:12:00 UTC")
      expect( schedule_blocks[2][:to_time].to_s ).to eq("2015-01-06 14:45:00 UTC")
    end
  end

  describe "#create_schedule" do
    
  end
end

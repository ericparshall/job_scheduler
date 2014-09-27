require 'rails_helper'

RSpec.describe SchedulesController, :type => :controller do
  describe "#get_schedule_blocks" do
    it "should return a single schedule block" do
      schedule_item = {
        "0"=>{
          "from_time_date"=>"09/05/2014", "from_time_time"=>"1:00am", 
          "to_time_date"=>"09/05/2014", "to_time_time"=>"6:00am", 
          "through_date"=>"09/05/2014"
        }
      }
      
      schedule_block = SchedulesController.new.get_schedule_blocks(schedule_item)
      
      expect(schedule_block.size).to eq 1
      expect(schedule_block.first[:from_time]).to eq Time.parse("09/05/2014 1:00am UTC")
      expect(schedule_block.first[:to_time]).to eq Time.parse("09/05/2014 6:00am UTC")
    end
    
    it "should return a range of schedule blocks" do
      schedule_item = {
        "0"=>{
          "from_time_date"=>"09/05/2014", "from_time_time"=>"1:00am", 
          "to_time_date"=>"09/05/2014", "to_time_time"=>"6:00am", 
          "through_date"=>"09/10/2014"
        }
      }
      
      schedule_block = SchedulesController.new.get_schedule_blocks(schedule_item)
      
      expect(schedule_block.size).to eq 6
      expect(schedule_block[0][:from_time]).to eq Time.parse("09/05/2014 1:00am UTC")
      expect(schedule_block[0][:to_time]).to eq Time.parse("09/05/2014 6:00am UTC")
      
      expect(schedule_block[1][:from_time]).to eq Time.parse("09/06/2014 1:00am UTC")
      expect(schedule_block[1][:to_time]).to eq Time.parse("09/06/2014 6:00am UTC")
      
      expect(schedule_block[2][:from_time]).to eq Time.parse("09/07/2014 1:00am UTC")
      expect(schedule_block[2][:to_time]).to eq Time.parse("09/07/2014 6:00am UTC")
      
      expect(schedule_block[3][:from_time]).to eq Time.parse("09/08/2014 1:00am UTC")
      expect(schedule_block[3][:to_time]).to eq Time.parse("09/08/2014 6:00am UTC")
      
      expect(schedule_block[4][:from_time]).to eq Time.parse("09/09/2014 1:00am UTC")
      expect(schedule_block[4][:to_time]).to eq Time.parse("09/09/2014 6:00am UTC")
      
      expect(schedule_block[5][:from_time]).to eq Time.parse("09/10/2014 1:00am UTC")
      expect(schedule_block[5][:to_time]).to eq Time.parse("09/10/2014 6:00am UTC")
    end
    
    it "should return a range when passed a list of schedule times" do
      schedule_item = {
        "0"=>{
          "from_time_date"=>"09/05/2014", "from_time_time"=>"1:00am", 
          "to_time_date"=>"09/05/2014", "to_time_time"=>"6:00am", 
          "through_date"=>"09/11/2014"
        }, 
        "1"=>{
          "from_time_date"=>"09/06/2014", "from_time_time"=>"2:00pm", 
          "to_time_date"=>"09/06/2014", "to_time_time"=>"6:00pm"
        }, 
        "2"=>{
          "from_time_date"=>"09/07/2014", "from_time_time"=>"1:12am", 
          "to_time_date"=>"09/07/2014", "to_time_time"=>"6:55am"
        }, 
        "3"=>{
          "from_time_date"=>"09/09/2014", "from_time_time"=>"1:00am", 
          "to_time_date"=>"09/09/2014", "to_time_time"=>"6:00pm"
        }
      }
      
      schedule_block = SchedulesController.new.get_schedule_blocks(schedule_item)
      
      expect(schedule_block.size).to eq 4
      expect(schedule_block[0][:from_time]).to eq Time.parse("09/05/2014 1:00am UTC")
      expect(schedule_block[0][:to_time]).to eq Time.parse("09/05/2014 6:00am UTC")
      
      expect(schedule_block[1][:from_time]).to eq Time.parse("09/06/2014 2:00pm UTC")
      expect(schedule_block[1][:to_time]).to eq Time.parse("09/06/2014 6:00pm UTC")
      
      expect(schedule_block[2][:from_time]).to eq Time.parse("09/07/2014 1:12am UTC")
      expect(schedule_block[2][:to_time]).to eq Time.parse("09/07/2014 6:55am UTC")
      
      expect(schedule_block[3][:from_time]).to eq Time.parse("09/09/2014 1:00am UTC")
      expect(schedule_block[3][:to_time]).to eq Time.parse("09/09/2014 6:00pm UTC")
    end
  end
  
  describe "#schedule_conflicts" do
    before :each do
      @users = []
      4.times { @users << Fabricate(:user) }
      @user_ids = {}
      @users.each {|user| @user_ids[user.id.to_s] = user.full_name }
      signed_in_as_a_valid_user
    end
    
    it "should check for conflics for each user" do
      expect(controller).to receive(:get_schedule_blocks).and_return(
        [ { from_time: Time.parse("09/05/2014 1:00am"), to_time: Time.parse("09/05/2014 6:00am UTC") } ]
      )
      expect(ScheduleConflictChecker).to receive(:check_schedule_for_conflicts).exactly(4).times.and_return({errors: [], warnings: []})
      get :schedule_conflicts, user_ids: @user_ids, schedule: { job_id: "1" }
      expect(assigns[:errors]).to eq [] 
      expect(assigns[:warnings]).to eq [] 
    end
  end
end

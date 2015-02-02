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

  describe '#get_available_employees' do
    before :each do
      signed_in_as_a_valid_user

      @user_1 = Fabricate(:user, full_name: 'user 1')
      @user_2 = Fabricate(:user, full_name: 'user 2')
      @user_3 = Fabricate(:user, full_name: 'user 3')
      @user_4 = Fabricate(:user, full_name: 'user 4')
      @user_5 = Fabricate(:user, full_name: 'user 5')
      @user_6 = Fabricate(:user, full_name: 'user 6')
      @user_7 = Fabricate(:user, full_name: 'user 7')
      @user_8 = Fabricate(:user, full_name: 'user 8')
      @user_9 = Fabricate(:user, full_name: 'user 9')
      @user_10 = Fabricate(:user, full_name: 'user 10')

      Fabricate(:schedule,
                      user_id: @user_1.id,
                      job_id: 1,
                      from_time: Time.parse('2015-01-01T09:00:00.000Z'),
                      to_time: Time.parse('2015-01-01T17:30:00.000Z')
      )
      Fabricate(:schedule,
                      user_id: @user_2.id,
                      job_id: 1,
                      from_time: Time.parse('2015-01-03T11:15:00.000Z'),
                      to_time: Time.parse('2015-01-03T15:30:00.000Z')
      )
      Fabricate(:schedule,
                      user_id: @user_3.id,
                      job_id: 1,
                      from_time: Time.parse('2015-01-06T01:12:00.000Z'),
                      to_time: Time.parse('2015-01-06T14:45:00.000Z')
      )
      Fabricate(:schedule,
                      user_id: @user_4.id,
                      job_id: 1,
                      from_time: Time.parse('09/05/2014 1:00am UTC'),
                      to_time: Time.parse('09/05/2014 6:00am UTC')
      )
      Fabricate(:schedule,
                      user_id: @user_5.id,
                      job_id: 1,
                      from_time: Time.parse('09/05/2014 1:00am UTC'),
                      to_time: Time.parse('09/05/2014 6:00am UTC')
      )
      Fabricate(:schedule,
                      user_id: @user_6.id,
                      job_id: 1,
                      from_time: Time.parse('09/05/2014 1:00am UTC'),
                      to_time: Time.parse('09/05/2014 6:00am UTC')
      )

      Fabricate(:schedule,
                user_id: @user_7.id,
                job_id: 1,
                from_time: Time.parse('2015-01-01T01:00:00.000Z'),
                to_time: Time.parse('2015-01-01T02:59:00.000Z')
      )
      Fabricate(:schedule,
                user_id: @user_8.id,
                job_id: 1,
                from_time: Time.parse('2015-01-01T01:00:00.000Z'),
                to_time: Time.parse('2015-01-01T03:05:00.000Z')
      )
      Fabricate(:schedule,
                user_id: @user_9.id,
                job_id: 1,
                from_time: Time.parse('2015-01-06T20:40:00.000Z'),
                to_time: Time.parse('2015-01-06T21:40:00.000Z')
      )
      Fabricate(:schedule,
                user_id: @user_10.id,
                job_id: 1,
                from_time: Time.parse('2015-01-06T20:45:00.000Z'),
                to_time: Time.parse('2015-01-06T21:45:00.000Z')
      )
    end

    it 'should work' do
      times = [{
                       '$$hashKey' => 'object:7',
                       'from_time' => '2015-01-01T09:00:00.000Z',
                       'through_date' => '2015-01-08T00:00:00.000Z',
                       'to_time' => '2015-01-01T17:30:00.000Z'
                   },
                   {
                       '$$hashKey' => 'object:8',
                       'from_time' => '2015-01-03T11:15:00.000Z',
                       'to_time' => '2015-01-03T15:30:00.000Z'
                   },
                   {
                       '$$hashKey' => 'object:9',
                       'from_time' => '2015-01-06T01:12:00.000Z',
                       'to_time' => '2015-01-06T14:45:00.000Z'
                   }]
      post :get_available_employees, :format => :json, :schedule => {:time_ranges => times}.to_json

      available_users = JSON.parse response.body

      expect(available_users.detect {|u| u['full_name'] == 'user 4' }).to be
      expect(available_users.detect {|u| u['full_name'] == 'user 5' }).to be
      expect(available_users.detect {|u| u['full_name'] == 'user 6' }).to be
      expect(available_users.detect {|u| u['full_name'] == 'user 7' }).to be

      expect(available_users.detect {|u| u['full_name'] == 'user 1' }).to_not be
      expect(available_users.detect {|u| u['full_name'] == 'user 2' }).to_not be
      expect(available_users.detect {|u| u['full_name'] == 'user 3' }).to_not be
      expect(available_users.detect {|u| u['full_name'] == 'user 10' }).to_not be
    end
  end
end

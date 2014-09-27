require 'rails_helper'

RSpec.describe ScheduleConflictChecker, :type => :model do
  describe :schedules_conflict? do
    it "should return false if they don't overlap" do
      expect(
        ScheduleConflictChecker.schedules_conflict?(
          Fabricate.build(:schedule, from_time: Time.parse("01/01/2014 1:00am"), to_time: Time.parse("01/01/2014 7:00am")),
          Fabricate.build(:schedule, from_time: Time.parse("01/01/2014 7:00am"), to_time: Time.parse("01/01/2014 10:00am"))
        )
      ).to eq false
    end
    
    it "should return true if they do overlap" do
      expect(
        ScheduleConflictChecker.schedules_conflict?(
          Fabricate.build(:schedule, from_time: Time.parse("01/01/2014 1:00am"), to_time: Time.parse("01/01/2014 7:01am")),
          Fabricate.build(:schedule, from_time: Time.parse("01/01/2014 7:00am"), to_time: Time.parse("01/01/2014 10:00am"))
        )
      ).to eq true
      
      expect(
        ScheduleConflictChecker.schedules_conflict?(
          Fabricate.build(:schedule, from_time: Time.parse("01/01/2014 7:00am"), to_time: Time.parse("01/01/2014 10:00am")),
          Fabricate.build(:schedule, from_time: Time.parse("01/01/2014 9:59am"), to_time: Time.parse("01/01/2014 11:00am"))
        )
      ).to eq true
      
      expect(
        ScheduleConflictChecker.schedules_conflict?(
          Fabricate.build(:schedule, from_time: Time.parse("01/01/2014 7:00am"), to_time: Time.parse("01/01/2014 10:00am")),
          Fabricate.build(:schedule, from_time: Time.parse("01/01/2014 8:00am"), to_time: Time.parse("01/01/2014 9:00am"))
        )
      ).to eq true
      
      expect(
        ScheduleConflictChecker.schedules_conflict?(
          Fabricate.build(:schedule, from_time: Time.parse("01/01/2014 8:00am"), to_time: Time.parse("01/01/2014 9:00am")),
          Fabricate.build(:schedule, from_time: Time.parse("01/01/2014 7:00am"), to_time: Time.parse("01/01/2014 10:00am"))
        )
      ).to eq true
    end
  end
  
  describe :total_schedules_hours do
    it "should return the correct number of times" do
      expect(
        ScheduleConflictChecker.total_schedules_hours(Time.parse("01/01/2014 11:00am").beginning_of_week, [
          Fabricate.build(:schedule, from_time: Time.parse("01/01/2014 8:00am"), to_time: Time.parse("01/01/2014 9:00am")), #1
          Fabricate.build(:schedule, from_time: Time.parse("01/01/2014 7:45am"), to_time: Time.parse("01/01/2014 9:00pm")), #13.25
          Fabricate.build(:schedule, from_time: Time.parse("01/01/2014 12:15pm"), to_time: Time.parse("01/02/2014 9:00am")) #20.75
          ])
      ).to eq 35
    end
  end
  
  describe :week_blocks do
    it "should only add a schedule once if it does not cross weeks" do
      schedule_a = Fabricate.build(:schedule, from_time: Time.parse("01/01/2014 8:00am"), to_time: Time.parse("01/01/2014 9:00am"))
      schedule_b = Fabricate.build(:schedule, from_time: Time.parse("01/08/2014 8:00am"), to_time: Time.parse("01/08/2014 9:00am"))
      week_blocks = ScheduleConflictChecker.week_blocks [schedule_a, schedule_b]
      expect( week_blocks[schedule_a.from_time.beginning_of_week].size ).to eq 1
      expect( week_blocks[schedule_a.from_time.beginning_of_week].first ).to eq schedule_a
      expect( week_blocks[schedule_b.from_time.beginning_of_week].size ).to eq 1
      expect( week_blocks[schedule_b.from_time.beginning_of_week].first ).to eq schedule_b
    end
    
    it "should only add a schedule twice if it does cross weeks" do
      schedule_a = Fabricate.build(:schedule, from_time: "09/07/2014 8:00pm", to_time: "09/08/2014 4:00am")
      expect( schedule_a.from_time.beginning_of_week ).to_not eq schedule_a.to_time.beginning_of_week
      week_blocks = ScheduleConflictChecker.week_blocks [schedule_a]
      expect( week_blocks.size ).to eq 2
      expect( week_blocks[schedule_a.from_time.beginning_of_week].size ).to eq 1
      expect( week_blocks[schedule_a.from_time.beginning_of_week].first ).to eq schedule_a
      expect( week_blocks[schedule_a.to_time.beginning_of_week].size ).to eq 1
      expect( week_blocks[schedule_a.to_time.beginning_of_week].first ).to eq schedule_a
    end
  end
  
  describe :get_existing_schedules do
    before :each do
      @user_id = 1
      @schedule_a = Fabricate(:schedule, from_time: "09/07/2014 8:00pm", to_time: "09/08/2014 4:00am", user_id: @user_id)
      @schedule_b = Fabricate(:schedule, from_time: "09/08/2014 8:00pm", to_time: "09/09/2014 4:00am", user_id: @user_id)
      @schedule_c = Fabricate(:schedule, from_time: "09/11/2014 8:00pm", to_time: "09/12/2014 4:00am", user_id: @user_id)
      @schedule_d = Fabricate(:schedule, from_time: "09/13/2014 8:00pm", to_time: "09/14/2014 4:00am", user_id: @user_id)
      @schedule_e = Fabricate(:schedule, from_time: "09/14/2014 8:00pm", to_time: "09/15/2014 4:00am", user_id: @user_id)
      @schedule_f = Fabricate(:schedule, from_time: "09/22/2014 8:00pm", to_time: "09/23/2014 4:00am", user_id: @user_id)
    end
    
    it "should include schedules within a timeframe and exclude schedules outside of the timeframe - a" do
      schedule_week_blocks = {
        @schedule_b.from_time.beginning_of_week => [],
        @schedule_e.to_time.beginning_of_week => []
      }
      schedules = ScheduleConflictChecker.get_existing_schedules(schedule_week_blocks, 1, false, nil)
      expect( schedules.count ).to eq 5
      expect( schedules ).to include @schedule_a
      expect( schedules ).to include @schedule_b
      expect( schedules ).to include @schedule_c
      expect( schedules ).to include @schedule_d
      expect( schedules ).to include @schedule_e
    end
    
    it "should include schedules within a timeframe and exclude schedules outside of the timeframe - b" do
      schedule_week_blocks = {
        @schedule_b.from_time.beginning_of_week => []
      }
      schedules = ScheduleConflictChecker.get_existing_schedules(schedule_week_blocks, 1, false, nil)
      expect( schedules.count ).to eq 5
      expect( schedules ).to include @schedule_a
      expect( schedules ).to include @schedule_b
      expect( schedules ).to include @schedule_c
      expect( schedules ).to include @schedule_d
      expect( schedules ).to include @schedule_e
    end
    
    it "should include schedules within a timeframe and exclude schedules outside of the timeframe - c" do
      schedule_week_blocks = {
        @schedule_e.to_time.beginning_of_week => []
      }
      schedules = ScheduleConflictChecker.get_existing_schedules(schedule_week_blocks, 1, false, nil)
      expect( schedules.count ).to eq 1
      expect( schedules ).to include @schedule_e
    end
  end
end

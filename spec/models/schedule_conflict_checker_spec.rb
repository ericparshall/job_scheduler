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
end

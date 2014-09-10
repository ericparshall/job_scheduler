class ScheduleConflictChecker
  def self.check_schedule_for_conflicts(schedules)
    total_hours = total_schedules_hours(schedules)
    errors = []
    warnings = []
    
    query = Schedule.where([
      "schedule_date >= ? AND schedule_date <= ? and user_id = ?", 
      schedule.schedule_date.beginning_of_week, 
      schedule.schedule_date.end_of_week, 
      schedule.user_id])
      
    if schedule.persisted?
      query = query.where(["id != ?", schedule.id])
    end
    
    query.each do |s|
      schedules.each do |t|
        if schedules_conflict?(t, s)
          errors << "<strong>#{t.user.full_name}</strong>: The schedule conflicts with another schedule: <a href=\"#{schedule_path(s)}\">#{s.job.name}</a>".html_safe
        end
      end
      total_hours += s.hours
    end

    if total_hours >= 40
      warnings << "Including this schedule, <strong>#{schedule.user.full_name}</strong> is scheduled for #{hours} hours during the week".html_safe
    end
    
    { errors: errors, warnings: warnings }
  end
  
  def self.total_schedules_hours(schedules)
    (schedule.to_time - schedule.from_time) / 3600.0 * schedules.count
  end
  
  def self.schedules_conflict?(schedule_a, schedule_b)
    (schedule_a.from_time - schedule_b.to_time) * (schedule_b.from_time - schedule_a.to_time) > 0
  end
end

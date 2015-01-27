class ScheduleConflictChecker
  def self.check_schedule_for_conflicts(schedules)
    errors = []
    warnings = []
    
    if !schedules.first.nil?
      schedule_week_blocks = week_blocks(schedules)
      existing_schedules = get_existing_schedules(schedule_week_blocks, schedules.first.user_id, schedules.first.persisted?, schedules.first)
    
      existing_schedules.each do |existing_schedule|
        schedules.each do |schedule|
          if schedules_conflict?(schedule, existing_schedule)
            errors << "<strong>#{existing_schedule.user.full_name}</strong>: The schedule conflicts with another schedule: <a target=\"_blank\" href=\"/schedules/#{existing_schedule.id}\">#{existing_schedule.job.name}</a>".html_safe
            break
          end
        end
      end
    
      existing_schedule_week_blocks = week_blocks(existing_schedules)
      schedule_week_blocks.each do |beginning_of_week, weeks_schedules|
        existing_weeks_schedules = existing_schedule_week_blocks[beginning_of_week] || []
        total_hours = total_schedules_hours(beginning_of_week, weeks_schedules.zip(existing_weeks_schedules).flatten.compact)
      
        if total_hours >= 40
          warnings << "Including this schedule, <strong>#{schedules.first.user.full_name}</strong> is scheduled for #{total_hours} hours during the week beginning #{beginning_of_week.strftime("%Y-%m-%d")}".html_safe
        end
      end
    end
    
    { errors: errors, warnings: warnings }
  end
  
  def self.total_schedules_hours(beginning_of_week, schedules)
    end_of_week = beginning_of_week.end_of_week
    schedules.map do |schedule|
      if schedule.from_time < beginning_of_week
        from_time = beginning_of_week 
      else
        from_time = schedule.from_time
      end
      if schedule.to_time > end_of_week
        to_time = beginning_of_week.end_of_week
      else
        to_time = schedule.to_time
      end
      (to_time - from_time) / 3600.0 
    end.inject(0) {|total, hours| total += hours }
  end
  
  def self.schedules_conflict?(schedule_a, schedule_b)
    (schedule_a.from_time - schedule_b.to_time) * (schedule_b.from_time - schedule_a.to_time) > 0
  end
  
  def self.week_blocks(schedules)
    blocks = {}
    
    schedules.each do |schedule|
      from_time_week = schedule.from_time.beginning_of_week
      to_time_week = schedule.to_time.beginning_of_week
      
      blocks[schedule.from_time.beginning_of_week] ||= []
      blocks[schedule.from_time.beginning_of_week] << schedule
      
      if from_time_week != to_time_week
        blocks[schedule.to_time.beginning_of_week] ||= []
        blocks[schedule.to_time.beginning_of_week] << schedule
      end
    end
    
    return blocks
  end
  
  def self.get_existing_schedules(schedule_week_blocks, user_id, persisted, schedule_id)
    puts schedule_week_blocks.keys.inspect
    min_time = schedule_week_blocks.keys.min
    max_time = schedule_week_blocks.keys.max.end_of_week
    query = Schedule.where([
      "((from_time >= ? AND from_time <= ?) OR (to_time >= ? AND to_time <= ?)) and user_id = ?", 
      min_time,
      max_time,
      min_time,
      max_time,
      user_id
    ])
    
    if persisted
      query = query.where(["id != ?", schedule_id])
    end
    return query
  end
end

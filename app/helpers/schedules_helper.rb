module SchedulesHelper
  def tab_active_schedules
    case
      when params[:archived] == "jobs" then { "All Jobs" => "active" }
      when params[:archived] == "employees" then { "All Employees" => "active" }
      when params[:archived] == "all" then { "All Schedules" => "active" }
      else { "Default" => "active" }
    end
  end
  
  def page_back_dates
    @page_back_dates ||= case params[:unit]
    when "today"
      [@from_date - 1.day, @from_date - 1.day]
    when "month"
      [@from_date.prev_month.beginning_of_month, @from_date.prev_month.end_of_month]
    when "week"
      [@from_date.prev_week.beginning_of_week, @from_date.prev_week.end_of_week]
    when "day"
      [@from_date - 1.day, @from_date - 1.day]
    end
    
    @page_back_dates
  end
  
  def page_forward_dates
    @page_forward_dates ||= case params[:unit]
    when "today"
      [@from_date + 1.day, @from_date + 1.day]
    when "month"
      [@from_date.next_month.beginning_of_month, @from_date.next_month.end_of_month]
    when "week"
      [@from_date.next_week.beginning_of_week, @from_date.next_week.end_of_week]
    when "day"
      [@from_date + 1.day, @from_date + 1.day]
    end
    
    @page_forward_dates
  end
  
  def default_schedule_date
    puts @schedule.inspect
    puts params[:for_date]
    puts for_date_to_time(params[:for_date])
    puts format_time_to_us(for_date_to_time(params[:for_date]))
    case 
    when @schedule.schedule_date then
      val = format_time_to_us(@schedule.try(:schedule_date))
    when params[:for_date] then 
      val = format_time_to_us(for_date_to_time(params[:for_date]))
    else 
      val = nil
    end
    return val
  end
  
  def default_from_time
    case
    when @schedule.schedule_date then format_time_to_hour(@schedule.from_time)
    when params[:for_date]then format_time_to_hour(for_date_to_time(params[:for_date]))
    else nil
    end
  end
end

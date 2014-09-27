module SchedulesHelper
  def tab_active_schedules
    case
      when params[:archived] == "jobs" then { "All Jobs" => "active" }
      when params[:archived] == "employees" then { "All Employees" => "active" }
      when params[:archived] == "all" then { "All Schedules" => "active" }
      else { "Default" => "active" }
    end
  end
  
  def tab_active_schedules_section
    case
    when params[:selected_tab] == "Summary" then { "Summary" => "active" }
    when params[:selected_tab] == "List" then { "List" => "active" }
    when params[:selected_tab] == "Calendar" then { "Calendar" => "active" }
    else { "Summary" => "active" }
    end
  end
  
  def page_back_dates
    @page_back_dates ||= case params[:unit]
    when "today"
      [@from_time - 1.day, @from_time - 1.day]
    when "month"
      [@from_time.prev_month.beginning_of_month, @from_time.prev_month.end_of_month]
    when "week"
      [@from_time.prev_week.beginning_of_week, @from_time.prev_week.end_of_week]
    when "day"
      [@from_time - 1.day, @from_time - 1.day]
    end
    
    @page_back_dates.map {|d| d.strftime('%m/%d/%Y') }
  end
  
  def page_forward_dates
    @page_forward_dates ||= case params[:unit]
    when "today"
      [@from_time + 1.day, @from_time + 1.day]
    when "month"
      [@from_time.next_month.beginning_of_month, @from_time.next_month.end_of_month]
    when "week"
      [@from_time.next_week.beginning_of_week, @from_time.next_week.end_of_week]
    when "day"
      [@from_time + 1.day, @from_time + 1.day]
    end
    
    @page_forward_dates.map {|d| d.strftime('%m/%d/%Y') }
  end
  
  def default_schedule_date(for_attr)
    case 
    when defined?(@future_schedule) && !@future_schedule.nil? then
      if for_attr == :from_time
        val = format_time_to_us(@future_schedule.from_time)
      elsif for_attr == :to_time
        val = format_time_to_us(@future_schedule.to_time)
      elsif for_attr == :through_date
        val = format_time_to_us(@future_schedule.through_date)
      end
    when @schedule.try(for_attr) then
      val = format_time_to_us(@schedule.try(for_attr))
    when params[:for_date] then 
      val = format_time_to_us(for_date_to_time(params[:for_date]))
    else 
      val = nil
    end
    return val
  end
  
  def default_from_time(for_attr)
    case
    when defined?(@future_schedule) && !@future_schedule.nil? then
      format_time_to_hour(@future_schedule.send(for_attr))
    when @schedule.send(for_attr) then 
      format_time_to_hour(@schedule.send(for_attr))
    when params[:for_date] then 
      format_time_to_hour(for_date_to_time(params[:for_date]))
    else nil
    end
  end
  
  def calendar_view_default_view
    case
    when ["today","day"].include?(params[:unit]) then "basicDay"
    when params[:unit] == "week" then "basicWeek"
    else "month"
    end
  end
end

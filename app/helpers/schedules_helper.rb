module SchedulesHelper
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
end

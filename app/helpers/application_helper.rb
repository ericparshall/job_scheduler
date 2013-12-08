module ApplicationHelper
  def for_date_to_time(for_date)
    Time.at(for_date.to_i)# rescue nil
  end
  
  def format_time_to_hour(time)
    time.try(:strftime, "%I:%M%P")
  end
  
  def format_time_to_us(time)
    time.try(:strftime, "%m/%d/%Y")
  end
  
  def menu_class(section)
    section == controller_name ? "active" : ""
  end
  
  def show_admin_section
    yield if current_user.try(:user_type).try(:admin?)
  end
end

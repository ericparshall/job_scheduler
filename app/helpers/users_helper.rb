module UsersHelper
  def tab_active
    case
    when params[:archived] == "true" then { "Archived" => "active" }
    else { "Default" => "active" }
    end
  end
end

module ApplicationHelper


  def flash_class(level)
    case level
      when 'info' then "alert alert-info"
      when 'notice','success' then "alert alert-success"
      when 'error' then "alert alert-danger"
      when 'alert' then "alert alert-warning"
    end
  end

  def check_current_page_show_this_part?
    if current_page?(user_session_url) || current_page?(new_user_session_url) || current_page?(new_user_registration_url) || current_page?(insints_url) || current_page?(new_user_password_url) || current_page?(edit_user_password_url)
      false
    else
      true
    end
  end

  def current_page_path_as_class
    request.path.split("?").first[1..-1].gsub("/","_")
  end

end

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
    not_show = ['users_sign_in','users_sign_up','users_password_new']
    if not_show.include?( current_page_path_as_class )
      false
    else
      true
    end
  end

  def current_page_path_as_class
    request.path.split("?").first[1..-1].gsub("/","_")
  end

end

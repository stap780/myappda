module ApplicationHelper
  def flash_class(level)
    case level
    when "info" then "alert alert-info"
    when "notice", "success" then "alert alert-success"
    when "error" then "alert alert-danger"
    when "alert" then "alert alert-warning"
    end
  end

  def status_class(mycase_status)
    case mycase_status
    when 'new' then 'text-primary text-opacity-75'
    when 'take' then 'text-secondary text-opacity-75'
    when 'finish' then 'text-success text-opacity-75'
  end

  def check_current_page_show_this_part?
    not_show = ["users", "users_sign_in", "users_sign_up", "users_password_new"]
    if not_show.include?(current_page_path_as_class)
      false
    else
      true
    end
  end

  def current_page_path_as_class
    request.path.split("?").first[1..-1].tr("/", "_")
  end

  def close_icon
    '<i class="bi bi-x"></i>'.html_safe
  end

  def eye_icon
    '<i class="bi bi-eye"></i>'.html_safe
  end

  def div_check_box_tag_all
    content_tag :div, class: "col-1 d-flex self-content-start" do
      check_box_tag("selectAll", "selectAll", class: "checkboxes form-check-input", data: {select_all_target: "checkboxAll", action: "change->select-all#toggleChildren"})
    end
  end

  def arrow_left_right_icon
    '<i class="bi bi-arrow-left-right"></i>'.html_safe
  end

  def arrow_clockwise_icon
    "<i class='bi bi-arrow-clockwise'></i>".html_safe
  end

  def search_icon
    "<i class='bi bi-search'></i>".html_safe
  end

  def heart_icon
    '<i class="bi bi-heart"></i>'.html_safe
  end

  def bell_icon
    '<i class="bi bi-bell"></i>'.html_safe
  end

  def reload_icon
    "<i class='bi bi-arrow-repeat'></i>".html_safe
  end

  def mail_icon
    "<i class='bi bi-envelope'></i>".html_safe
  end

  def arrow_right_icon
    '<i class="bi bi-arrow-right"></i>'.html_safe
  end

  def prepend_flash
    turbo_stream.prepend "our_flash", partial: "shared/flash"
  end

  def download_icon
    '<i class="bi bi-download"></i>'.html_safe
  end

  def false_icon
    '<i class="bi bi-x-circle"></i>'.html_safe
  end

  def true_icon
    '<i class="bi bi-check-circle"></i>'.html_safe
  end

  def more_icon
    '<i class="bi bi-three-dots"></i>'.html_safe
  end

  def download_icon_cloud
    '<i class="bi bi-cloud-arrow-down"></i>'.html_safe
  end

  def export_file_icon
    '<i class="bi bi-file-arrow-down"></i>'.html_safe
  end

  def arrow_up
    '<i class="bi bi-arrow-up"></i>'.html_safe
  end

  def upload_cloud_icon
    '<i class="bi bi-cloud-arrow-up"></i>'.html_safe
  end

  def sidekiq_icon
    '<i class="bi bi-app"></i>'.html_safe
  end

  def add_icon
    "<i class='bi bi-plus'></i> #{t("add")}".html_safe
  end

  def play_icon
    '<i class="bi bi-play"></i>'.html_safe
  end

  def cart_icon
    '<i class="bi bi-cart"></i>'.html_safe
  end

  def edit_icon
    '<i class="bi bi-pencil"></i>'.html_safe
  end

  def trash_icon
    '<i class="bi bi-trash3"></i>'.html_safe
  end

  def td_tag_image(img_link = nil)
    content_tag :td, class: "p-0 d-flex align-items-center justify-content-center" do
      content_tag :div, class: "img-ratio img-fit", style: "width:80px;" do
        content_tag :div, class: "img-ratio__inner" do
          picture_tag([img_link], image: {class: "img-fluid img-thumbnail", loading: "lazy"}) if img_link.present?
        end
      end
    end
  end
end

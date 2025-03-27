module ApplicationHelper
  def flash_class(level)
    case level
    when 'info' then 'alert alert-info'
    when 'notice', 'success' then 'alert alert-success'
    when 'error' then 'alert alert-danger'
    when 'alert' then 'alert alert-warning'
    end
  end

  def status_class(mycase_status)
    status_classes = {
      'new' => 'text-primary text-opacity-75',
      'take' => 'text-secondary text-opacity-75',
      'finish' => 'text-success text-opacity-75'
    }
    status_classes[mycase_status]
  end

  def check_current_page_show_this_part?
    not_show = %w[users users_sign_in users_sign_up users_password_new]
    if not_show.include?(current_page_path_as_class)
      false
    else
      true
    end
  end

  def current_page_path_as_class
    request.path.split('?').first[1..-1].tr('/', '_')
  end

  def close_icon
    '<i class="bi bi-x"></i>'.html_safe
  end

  def eye_icon
    '<i class="bi bi-eye"></i>'.html_safe
  end

  def order_icon
    '<i class="bi bi-card-list"></i>'.html_safe
  end

  def client_icon
    '<i class="bi bi-person-standing"></i>'.html_safe
  end

  def product_icon
    '<i class="bi bi-box-seam"></i>'.html_safe
  end

  def div_check_box_tag_all
    content_tag :div, class: 'col-1 d-flex self-content-start' do
      check_box_tag('selectAll', 'selectAll', class: 'checkboxes form-check-input', data: {select_all_target: 'checkboxAll', action: 'change->select-all#toggleChildren'})
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
    turbo_stream.prepend 'our_flash', partial: 'shared/flash'
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
    "<i class='bi bi-plus'></i> #{t(:add)}".html_safe
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
    content_tag :td, class: '' do
      content_tag :div, class: 'img-ratio img-fit', style: 'width:80px;' do
        content_tag :div, class: 'img-ratio__inner' do
          picture_tag([img_link], image: {class: 'img-fluid m-0 p-2', loading: 'lazy'}) if img_link.present?
        end
      end
    end
  end

  def image_block(img_link = nil)
    content_tag :div, class: 'd-block p-0' do
      content_tag :div, class: 'img-ratio img-fit' do
        content_tag :div, class: 'img-ratio__inner' do
          picture_tag([img_link], image: {class: 'img-fluid m-0 p-2', loading: 'lazy'}) if img_link.present?
        end
      end
    end
  end
end

def sortable_icon
  '<i class="bi bi-arrows-move js-sort-handle fs-3"></i>'.html_safe
end

def sortable_with_badge(position)
  content_tag :i, class: 'bi bi-arrows-move js-sort-handle fs-6 position-relative me-2 pt-1 pe-0' do
    content_tag(:span, position, class: 'badge bg-info fs-8 p-1 rounded-circle position-absolute top-0 start-100 translate-middle border border-light','data-sortable-target':'position')
  end
end

def button_print
  '<button class="btn btn-outline-info btn-sm dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false"><i class="bi bi-printer"></i></button>'.html_safe
end


def button_bulk_delete
  '<button class="btn btn-outline-info btn-sm dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false"><i class="bi bi-trash3"></i></button>'.html_safe
end

def li_menu_link_to(name = nil, options = nil, html_options = nil, &block)
  status = current_page?(options) ? 'active' : ''
  content_tag :li, class: "nav-item #{status}" do
    link_to(name, options, html_options, &block)
  end
end

def button_download
  '<button class="btn btn-outline-info dropdown-toggle btn-sm" type="button" data-bs-toggle="dropdown" aria-expanded="false">.xlsx</button>'.html_safe
end
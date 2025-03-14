# UsersHelper
module UsersHelper
  def user_client_info(user)
    content = content_tag(:span, '', class: 'no-wrap')
    content << content_tag(
      :span,
      user.clients_count,
      class: 'no-wrap fw-bold cursor-pointer',
      'data-controller': 'tooltip',
      'data-bs-trigger': 'hover click',
      'data-bs-placement': 'right',
      'data-bs-title': user.last_client_data
    )
    content_tag :div, class: 'd-flex justify-content-start gap-2 align-items-center' do
      content
    end
  end

end
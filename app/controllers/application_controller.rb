class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception
  # rescue_from ActionController::Redirecting::UnsafeRedirectError do
  #   redirect_to root_url
  # end
  protect_from_forgery with: :null_session
  impersonates :user

  before_action :authenticate_user!
  before_action :set_current_user
  # before_action :redirect_to_subdomain  # Every logged in user should be redirected to their own subdomain
  ## before_action :allow_cross_domain_ajax
  # before_action :allow_cross_domain_access
  # after_action :cors_set_access_control_headers
  helper_method :current_admin
  helper_method :authenticate_admin!


  def render_turbo_flash
    turbo_stream.update("our_flash", partial: "shared/flash")
  end

  ## def allow_cross_domain_ajax
  ##     headers['Access-Control-Allow-Origin'] = '*'
  ##     headers['Access-Control-Request-Method'] = 'GET, POST, OPTIONS'
  ## end

  # def allow_cross_domain_access
  #     headers['Access-Control-Allow-Origin'] = '*' #http://localhost:9000
  #     headers['Access-Control-Allow-Headers'] = 'GET, POST, PUT, DELETE, OPTIONS'
  #     headers['Access-Control-Allow-Methods'] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token}.join(',')
  #     headers['Access-Control-Max-Age'] = '1728000'
  # end

  # def cors_set_access_control_headers
  #     headers['Access-Control-Allow-Origin'] = '*'
  #     headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
  #     headers['Access-Control-Allow-Headers'] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token}.join(',')
  #     headers['Access-Control-Max-Age'] = "1728000"
  # end
  private

  def after_sign_in_path_for(resource_or_scope)
    puts "#{resource_or_scope.subdomain} - ApplicationController - after_sign_in_path_for"
    mycases_url(subdomain: resource_or_scope.subdomain)
  end

  def after_sign_out_path_for(resource_or_scope)
    root_url(subdomain: '')
  end

  def invoice_path_for(resource_or_scope)
    invoices_url(subdomain: resource_or_scope.subdomain)
  end

  # def redirect_to_subdomain
  #   puts "self.is_a?(DeviseController)"
  #   puts self.is_a?(DeviseController)
  #   puts "redirect_to_subdomain request.subdomain => "+ request.subdomain.to_s
  #   return if self.is_a?(DeviseController)

  #   if current_user.present? && request.subdomain != current_user.subdomain
  #     subdomain = current_user.subdomain
  #     host = request.host_with_port.sub! "#{request.subdomain}", subdomain
  #     puts "host - "+host.to_s
  #     redirect_to "http://#{host}#{request.path}"
  #   end
  # end


  def redirect_to_app_url
    return if request.subdomain.present? && request.subdomain == 'app'

    url = app_url
    redirect_to url, allow_other_host: true
  end

  def app_url
    puts "request.subdomain.present? "+request.subdomain.present?.to_s
    puts 'request.domain - '+request.domain.to_s
    puts 'request.subdomain - '+request.subdomain.to_s
    puts 'request.host_with_port '+request.host_with_port.to_s
    puts 'request.path '+request.path.to_s

    subdomain = 'app'

    if request.subdomain.present?
      host = request.host_with_port.sub! "#{request.subdomain}.", ''
    else
      host = request.host_with_port
    end # if

    "http://#{subdomain}.#{host}#{request.path}"
  end 

  def current_admin
    current_user.admin? if current_user.present?
  end

  def authenticate_admin!
    unless current_admin
      redirect_to useraccounts_path, alert: "У вас нет прав админа"
    end
  end

  def set_current_user
    User.current = current_user
  end

end

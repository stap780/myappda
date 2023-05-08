class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception
  protect_from_forgery with: :null_session

  before_action :authenticate_user!
  before_action :set_current_user
  before_action :redirect_to_subdomain  # Every logged in user should be redirected to their own subdomain
  ## before_action :allow_cross_domain_ajax
  # before_action :allow_cross_domain_access
  # after_action :cors_set_access_control_headers
  helper_method :current_admin
  helper_method :authenticate_admin!

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
    puts resource_or_scope.subdomain + " - это из ApplicationController - after_sign_in_path_for"
    dashboard_url(subdomain: resource_or_scope.subdomain)
  end # after_sign_in_path_for

  def after_sign_out_path_for(resource_or_scope)
    url = request.host_with_port.gsub("#{request.subdomain}.","")
    "http://"+url
  end

  def invoice_path_for(resource_or_scope)
    invoices_url(subdomain: resource_or_scope.subdomain)
  end # invoice_path_for


  def redirect_to_subdomain
    return if self.is_a?(DeviseController)
    if request.subdomain.present?
      if current_user.present? && request.subdomain != current_user.subdomain
        subdomain = current_user.subdomain
        host = request.host_with_port.sub!("#{request.subdomain}", subdomain)
        redirect_to "http://#{host}#{request.path}"
      end
    end
  end # redirect_to_subdomain


  def redirect_to_app_url
    return if request.subdomain.present? && request.subdomain == 'app'
    url = app_url
    redirect_to url
  end

  def app_url
    puts request.subdomain.present?
    puts 'request.domain - '+request.domain.to_s
    puts 'request.subdomain - '+request.subdomain.to_s
    puts 'request.host_with_port '+request.host_with_port.to_s
    puts 'request.path '+request.path.to_s

    subdomain = 'app'

    if request.subdomain.present?
      # host = request.host_with_port.sub! "#{request.subdomain}.", ''
      host = request.host_with_port.remove("#{request.subdomain}.")
    else
      host = request.host_with_port
    end

    app_url = "http://#{subdomain}.#{host}#{request.path}"
    puts app_url
    app_url

  end # app_url

  def current_admin
    if current_user.present?
      admin1 = Rails.application.secrets.admin1
      admin2 = Rails.application.secrets.admin2
      current_user.subdomain == admin1 || current_user.subdomain == admin2 || current_user.admin?
    end
  end

  def authenticate_admin!
    unless current_admin
      redirect_to useraccounts_path, alert: "У вас нет прав админа"
    end
  end

  def set_current_user
    User.current = current_user
  end



end # class

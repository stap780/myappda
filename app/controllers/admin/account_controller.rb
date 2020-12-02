class Admin::AccountController < Admin::BaseController
  def index
    @invoices = Invoice.all
    @users = User.all
    @payplans = Payplan.all
  end

  def switch_to_tenant
    Apartment::Tenant.switch!(params[:tenant])
    sign_in(User.find_by(subdomain: params[:tenant]))
    redirect_to dashboard_index_path
  end
end

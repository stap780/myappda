class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    service = current_user.insints.first.present? ? ApiInsales.new(current_user.insints.first) : nil
    @ins_account = service.present? && service.work? ? service.account : nil
    respond_to do |format|
		  format.html
		end
  end

  def show; end

  def test_email
    User.service_end_email
    flash[:notice] = 'Отправили'
		redirect_to dashboard_path
  end

  def services; end

  def fullsearch
    if params[:query].present?
      @search_results = Dashboard.search(params[:query])
      render turbo_stream: turbo_stream.replace('fullsearch_result', partial: 'dashboards/search/result')
    else
      render turbo_stream: turbo_stream.replace('fullsearch_result', partial: 'dashboards/search/result_empty')
    end
  end

end

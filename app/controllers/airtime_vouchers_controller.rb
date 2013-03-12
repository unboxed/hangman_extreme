class AirtimeVouchersController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource

  def index
    @airtime_vouchers = @airtime_vouchers.order("id DESC").page(params[:page]).per(10)
  end
end

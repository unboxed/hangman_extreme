class WinnersController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource

  def index
    params[:reason] ||= 'rating'
    params[:period] ||= 'daily'
    @winners = @winners.period(params[:period]).reason(params[:reason]).order('created_at DESC').page(params[:page]).per(10)
  end
end

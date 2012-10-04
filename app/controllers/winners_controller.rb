class WinnersController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource

  def index
    params[:reason] ||= 'daily_rating'
    @winners = @winners.where(['reason = ?',params[:reason]]).order('created_at DESC').page(params[:page]).per(10)
  end
end

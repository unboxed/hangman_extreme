class RedeemWinningsController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource

  def index
  end

  def new
    if params[:prize_type].present? && ['moola','clue_points'].include?(params[:prize_type])
      @redeem_winning.prize_type = params[:prize_type]
      @redeem_winning.prize_amount = params[:prize_amount].to_i
      @redeem_winning.state = 'pending'
    else
      redirect_to action: 'index'
    end
  end

  def create
    # @redeem_winning
    @redeem_winning.user = current_user
    begin
      RedeemWinning.transaction do
        @redeem_winning.save!
      end
      redirect_to({action: 'index'}, notice: 'prize successful')
    rescue
      redirect_to({action: 'index'}, alert: 'prize failed.')
    end
  end

end

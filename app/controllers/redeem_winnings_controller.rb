class RedeemWinningsController < ApplicationController
  before_filter :safe_redeem_winning_params, :only => [:new,:create]
  load_and_authorize_resource

  def index
  end

  def new
    if params[:prize_type].present? && RedeemWinning::PRIZE_TYPES.include?(params[:prize_type])
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
      if @redeem_winning.prize_type.include?('airtime')
          notice = "Please make sure you have entered your correct cellphone number on the profile page and allow 48 hours for your airtime to be paid out."
      else
        notice = 'prize successful'
      end
      redirect_to({action: 'index'}, notice: notice)
    rescue Exception => e
      ENV['AIRBRAKE_API_KEY'].present? ? notify_airbrake(e) : Rails.logger.error(e.message)
      redirect_to({action: 'index'}, alert: 'prize failed.')
    end
  end

  protected

  def safe_redeem_winning_params
    if params[:redeem_winning]
      params[:redeem_winning] = params[:redeem_winning].permit(:prize_amount, :prize_type, :state)
    end
  end

end

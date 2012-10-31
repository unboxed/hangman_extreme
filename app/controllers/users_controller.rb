class UsersController < ApplicationController
  before_filter :login_required, :except => :facebook_oauth
  load_and_authorize_resource :except => [:mxit_authorise,:mxit_oauth,:profile, :stats]
  caches_action :stats, expires_in: 1.day, :cache_path => proc{ {date: Date.today} }

  def index
    params[:period] = 'daily' unless Winner::WINNING_PERIODS.include?(params[:period].to_s)
    params[:rank_by] = 'rating' unless Winner::WINNING_REASONS.include?(params[:rank_by].to_s)
    @send = "#{params[:period]}_#{params[:rank_by]}"
    @users = @users.top_scorers(@send)
  end

  def edit

  end

  def update
    if @user.update_attributes(params[:user], as: 'user')
      redirect_to profile_users_path, notice: 'Profile was successfully updated.'
    else
      redirect_to profile_users_path, alert: @user.errors.inspect
    end
  end

  def show
    @user ||= current_user
  end

  def mxit_authorise
    redirect_to action: 'mxit_oauth', code: "MXITAUTH", state: params[:state]
  end

  def mxit_oauth
    if params[:code].blank?
      redirect_to mxit_oauth_redirect_to_path, alert: "Authorisation failed: #{params[:error].to_s}"
    else
      begin
        mxit_connection = MxitApi.connect(:grant_type => 'authorization_code',
                                          :code => params[:code],
                                          :redirect_uri => mxit_oauth_users_url(host: request.host))
        if mxit_connection
          if mxit_connection.scope.include?("profile")
            mxit_user_profile = mxit_connection.profile
            unless mxit_user_profile.empty?
              current_user.real_name = "#{mxit_user_profile[:first_name]} #{mxit_user_profile[:last_name]}" if current_user.real_name.blank?
              current_user.mobile_number = mxit_user_profile[:mobile_number] if current_user.mobile_number.blank?
              current_user.email = "#{request.env['HTTP_X_MXIT_LOGIN'] || mxit_user_profile[:user_id]}@mxit.im"
              current_user.save
            end
          end
          if mxit_connection.scope.include?("invite")
            mxit_connection.send_invite("m40363966002") # mxitid of extremepayout
          end
        end
      rescue Exception => e
        # ignore error
        ENV['AIRBRAKE_API_KEY'].present? ? notify_airbrake(e) : raise
      end
      redirect_to mxit_oauth_redirect_to_path
    end
  end

  def stats
    @cohort = User.cohort_array
    @cohort_percentage = @cohort.collect do |v|
      sum = v[1] + v[2] + v[3] + v[4] + v[5]
      if sum > 0
      [ v[0],
        (v[1] * 10000) / sum,
        (v[2] * 10000) / sum,
        (v[3] * 10000) / sum,
        (v[4] * 10000) / sum,
        (v[5] * 10000) / sum,
      ]
      else
        nil
      end
    end.compact
    @games_cohort = Game.cohort_array
    @games_cohort_percentage = @games_cohort.collect do |v|
      sum = v[1] + v[2] + v[3] + v[4]
      if sum > 0
      [ v[0],
        (v[1] * 10000) / sum,
        (v[2] * 10000) / sum,
        (v[3] * 10000) / sum,
        (v[4] * 10000) / sum,
      ]
      else
        nil
      end
    end.compact
    @winners_cohort = Winner.cohort_array
    @purchase_cohort = PurchaseTransaction.cohort_array

  end

  private

  def mxit_oauth_redirect_to_path
    if params[:state] == 'feedback'
      feedback_index_path
    elsif params[:state] == 'winnings'
      redeem_winnings_path
    else
      profile_users_path
    end
  end

end

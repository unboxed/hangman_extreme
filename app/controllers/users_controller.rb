class UsersController < ApplicationController
  before_filter :login_required, :except => :facebook_oauth
  load_and_authorize_resource :except => [:mxit_authorise,:mxit_oauth,:profile]

  def index
    params[:period]  ||= 'daily'
    params[:rank_by] ||= 'rating'
    case params[:rank_by]
      when 'wins'
        case params[:period]
          when 'weekly'
            @send = "games_won_this_week"
          when 'monthly'
            @send = "games_won_this_month"
          else
            @send = "games_won_today"
        end
      else
        @send = "#{params[:period]}_#{params[:rank_by]}"
    end
    @users = User.top_scorers(@send)
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
    @user = User.find_by_id(params[:id]) || current_user
  end

  def mxit_authorise
    redirect_to action: 'mxit_oauth', code: "MXITAUTH"
  end

  def mxit_oauth
    if params[:code].blank?
      redirect_to profile_users_path, alert: "Authorisation failed: #{params[:error].to_s}"
    else
      mxit_connection = MxitApi.connect(params[:code],profile_users_url(host: request.host))
      if mxit_connection
        mxit_user_profile = mxit_connection.profile
        unless mxit_user_profile.empty?
          current_user.real_name = "#{mxit_user_profile[:first_name]} #{mxit_user_profile[:last_name]}" if current_user.real_name.blank?
          current_user.mobile_number = mxit_user_profile[:mobile_number] if current_user.mobile_number.blank?
          current_user.save
        end
      end
      redirect_to profile_users_path
    end
  end

end

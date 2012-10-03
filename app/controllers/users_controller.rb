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
      basic_auth = Base64.encode64("#{ENV['MXIT_CLIENT_ID']}:#{ENV['MXIT_CLIENT_SECRET']}")
      access_token = nil
      RestClient.post('http://auth.mxit.com/token',
                      {:grant_type => 'authorization_code',
                       :code => params[:code],
                       :redirect_uri => profile_users_url(host: request.host)},
                      :accept => :json,
                      :authorization => "Basic #{basic_auth}") do |response, request, result, &block|
        case response.code
          when 200
            data = ActiveSupport::JSON.decode(response.body)
            access_token = data['access_token']
          else
            message = {response: response.inspect, request: request.inspect, result: result.inspect}.inspect
            ENV['AIRBRAKE_API_KEY'].present? ? notify_airbrake(Exception.new(message)) : Rails.logger.error(message)
            redirect_to profile_users_path, alert: "Authorisation failed"
        end
      end
      if access_token
        RestClient.get('http://auth.mxit.com/user/profile', :accept => :json, :authorization => "Bearer #{access_token}") do |response, request, result, &block|
          case response.code
            when 200
              data = ActiveSupport::JSON.decode(response.body)
              current_user.real_name = "#{data['FirstName']} #{data['LastName']}"
              current_user.mobile_number = data['MobileNumber']
              current_user.save
              redirect_to profile_users_path
            else
              message = {response: response.inspect, request: request.inspect, result: result.inspect}.inspect
              ENV['AIRBRAKE_API_KEY'].present? ? notify_airbrake(Exception.new(message)) : Rails.logger.error(message)
              redirect_to profile_users_path, alert: "Authorisation failed"
          end
        end
      end
    end
  end

end

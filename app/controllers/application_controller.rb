require 'cancan'
require 'staccato'
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_mxit_input_for_redirect, :check_for_mxit
  after_filter :send_stats

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  protected

  def current_user
    @current_user ||= User.find_or_create_from_auth_hash(provider: 'mxit',
                                                       uid: request.env['HTTP_X_MXIT_USERID_R'],
                                                       info: { name: request.env['HTTP_X_MXIT_NICK'],
                                                               login: request.env['HTTP_X_MXIT_LOGIN'],
                                                               email: request.env['HTTP_X_MXIT_LOGIN'] && "#{request.env['HTTP_X_MXIT_LOGIN']}@mxit.im"})
  end

  def current_user_request_info
    return @current_user_request_info if @current_user_request_info
    @current_user_request_info = UserRequestInfo.new
    if request.env['HTTP_X_MXIT_PROFILE']
      @mxit_profile = MxitProfile.new(request.env['HTTP_X_MXIT_PROFILE'])
      @current_user_request_info.mxit_profile = @mxit_profile
    end
    if request.env['HTTP_X_DEVICE_USER_AGENT']
      @current_user_request_info.user_agent = "Mxit #{request.env['HTTP_X_DEVICE_USER_AGENT']}"
    end
    if request.env['HTTP_X_MXIT_LOCATION']
      @mxit_location = MxitLocation.new(request.env['HTTP_X_MXIT_LOCATION'])
      @current_user_request_info.mxit_location = @mxit_location
    end
    @current_user_request_info
  end

  helper_method :current_user, :current_user_account, :current_user_request_info, :notify_airbrake

  def access_denied
    redirect_to('/', :alert => 'You are required to be logged')
    false
  end

  def send_stats
    if tracking_enabled? && status != 302 && current_user
      begin
        Timeout::timeout(15) do
          tracker = Staccato.tracker(tracking_code,GoogleTracking.tracking_uuid(current_user.id))
          hit = Staccato::Pageview.new(tracker,
                           path: request.fullpath,
                           hostname: request.host,
                           title: "#{params[:controller]} #{params[:action]}",
                           user_id: current_user.id,
                           user_ip: request.remote_ip,
                           user_agent: "#{request.env['HTTP_USER_AGENT']} #{current_user_request_info.user_agent}",
                           user_language: current_user_request_info.language || 'en')
          hit.add_custom_dimension(1,current_user_request_info.gender || 'unknown')
          hit.add_custom_metric(2,current_user_request_info.age || 'unknown')
          hit.track!
        end
      rescue Timeout::Error => te
        Rails.logger.warn(te.message)
        Settings.ga_tracking_disabled_until = 1.minute.from_now # disable for a 1 minute
      rescue => e
        ENV['AIRBRAKE_API_KEY'].present? ? notify_airbrake(e) : Rails.logger.error(e.message)
        Settings.ga_tracking_disabled_until = 20.minutes.from_now# disable for a 20 minutes
        raise e unless Rails.env.production?
      end
    end
  end

  def check_for_mxit
    if request.env['HTTP_X_MXIT_USERID_R'] || Rails.env.test?
      true
    else
      render file: 'public/401.html', status: :unauthorized, layout: nil
      false
    end
  end

  def check_mxit_input_for_redirect
    case request.env['HTTP_X_MXIT_USER_INPUT']
     when 'extremepayout'
      redirect_to(mxit_authorise_url(response_type: 'code',
                                    host: Rails.env.test? ? request.host : 'auth.mxit.com',
                                    protocol: Rails.env.test? ? 'http' : 'https',
                                    client_id: ENV['MXIT_CLIENT_ID'],
                                    redirect_uri: mxit_oauth_users_url(host: request.host),
                                    scope: 'contact/invite graph/read',
                                    state: 'winnings'))
      when 'options'
        redirect_to(options_users_path) unless params[:controller] == 'users'
      when 'winners'
        redirect_to(winners_path) unless params[:controller] == 'winners'
      when 'airtime vouchers'
        redirect_to(winners_path) unless params[:controller] == 'airtime_vouchers'
    end
    status != 302
  end

  private

  def tracking_enabled?
    tracking_code.present? &&
    (Settings.ga_tracking_disabled_until.blank? || Time.current > Settings.ga_tracking_disabled_until)
  end

  def tracking_code
    ENV['GA_TRACKING_CODE']
  end
end

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :load_mxit_user, :load_facebook_user, :check_mxit_input_for_redirect
  after_filter :send_stats
  layout :set_layout

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  protected

  def current_user
    @current_user ||= User.find_by_id(session[:current_user_id])
  end

  def current_user_request_info
    @current_user_request_info ||= UserRequestInfo.new
  end

  def mxit_request?
    !request.env['HTTP_X_MXIT_USERID_R'].nil?
  end

  helper_method :current_user, :current_user_request_info, :notify_airbrake, :mxit_request?

  def login_required
    return true if current_user
    access_denied
  end

  def access_denied
    Rails.env.development? ? redirect_to('/auth/developer') : redirect_to('/auth/facebook')
    false
  end

  def send_stats
    if tracking_enabled? && current_user && status != 302
      begin
        Timeout::timeout(15) do
          g = Gabba::Gabba.new(tracking_code, request.host)
          g.user_agent = current_user_request_info.user_agent || request.env['HTTP_USER_AGENT']
          g.utmul = current_user_request_info.language || "en"
          g.set_custom_var(1, 'Gender', current_user_request_info.gender || "unknown", 1)
          g.set_custom_var(2, 'Age', current_user_request_info.age || "unknown", 1)
          g.set_custom_var(3, current_user_request_info.country || "unknown Country", current_user_request_info.area || "unknown", 1)
          g.set_custom_var(5, 'Provider', current_user.provider, 1)
          g.identify_user(current_user.utma(true))
          g.ip(request.remote_ip)
          g.page_view("#{params[:controller]} #{params[:action]}", request.fullpath,current_user.id)
        end
      rescue Exception => e
        ENV['AIRBRAKE_API_KEY'].present? ? notify_airbrake(e) : Rails.logger.error(e.message)
        Settings.ga_tracking_disabled_until = 20.minutes.from_now# disable for a 20 minutes
        raise e unless Rails.env.production?
      end
    end
  end

  def load_mxit_user
    if request.env['HTTP_X_MXIT_USERID_R']
      @current_user = User.find_or_create_from_auth_hash(provider: 'mxit',
                                                              uid: request.env['HTTP_X_MXIT_USERID_R'],
                                                             info: { name: request.env['HTTP_X_MXIT_NICK'],
                                                                     login: request.env['HTTP_X_MXIT_LOGIN'] })
      if request.env["HTTP_X_MXIT_PROFILE"]
        @mxit_profile = MxitProfile.new(request.env["HTTP_X_MXIT_PROFILE"])
        current_user_request_info.mxit_profile = @mxit_profile
      end
      if request.env['HTTP_X_DEVICE_USER_AGENT']
        current_user_request_info.user_agent = "Mxit #{request.env['HTTP_X_DEVICE_USER_AGENT']}"
      end
      if request.env["HTTP_X_MXIT_LOCATION"]
        @mxit_location = MxitLocation.new(request.env["HTTP_X_MXIT_LOCATION"])
        current_user_request_info.mxit_location = @mxit_location
      end
    end
  end

  def set_layout
    mxit_request? ? 'mxit' : 'mobile'
  end

  def load_facebook_user
    if params[:signed_request]
      encoded_sig, payload = params[:signed_request].split('.')
      encoded_str = payload.gsub('-','+').gsub('_','/')
      encoded_str += '=' while !(encoded_str.size % 4).zero?
      @data = ActiveSupport::JSON.decode(Base64.decode64(encoded_str))
      if @data.kind_of?(Hash) && @data['user_id']
        self.current_user = User.find_or_create_from_auth_hash(provider: 'facebook',
                                                                    uid: @data['user_id'],
                                                                   info: { name: "user #{@data['user_id']}"})
      else
        redirect_to facebook_oauth_path
        false
      end
    end
  end

  def check_mxit_input_for_redirect
    case request.env["HTTP_X_MXIT_USER_INPUT"]
     when "extremepayout"
      redirect_to(mxit_authorise_url(response_type: 'code',
                                    host: Rails.env.test? ? request.host : "auth.mxit.com",
                                    protocol: Rails.env.test? ? 'http' : 'https',
                                    client_id: ENV['MXIT_CLIENT_ID'],
                                    redirect_uri: mxit_oauth_users_url(host: request.host),
                                    scope: "contact/invite graph/read",
                                    state: "winnings"))
      when "profile"
        redirect_to(profile_users_path) unless params[:action] == 'profile'
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

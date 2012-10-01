class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :load_mxit_user, :load_facebook_user
  after_filter :send_stats

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

  helper_method :current_user

  def login_required
    return true if current_user
    access_denied
  end

  def access_denied
    redirect_to '/auth/developer'
    false
  end

  def send_stats
    if tracking_enabled? && current_user
      begin
      g = Gabba::Gabba.new(tracking_code, "mxithangmanleague.herokuapp.com")
      g.user_agent = current_user_request_info.user_agent || request.env['HTTP_USER_AGENT']
      g.utmul = current_user_request_info.language || "en"
      g.set_custom_var(1, 'Gender', current_user_request_info.gender || "unknown", 1)
      g.set_custom_var(2, 'Age', current_user_request_info.age || "unknown", 1)
      g.set_custom_var(3, current_user_request_info.country || "unknown Country", current_user_request_info.area || "unknown", 1)
      g.set_custom_var(5, 'Provider', current_user.provider, 1)
      current_user.update_attribute(:utma,g.cookie_params(current_user.id)) unless current_user.utma?
      g.identify_user(current_user.utma) if current_user.utma?
      g.page_view("#{params[:controller]} #{params[:action]}", request.fullpath,current_user.id)
      rescue Exception => e
        Rails.logger.error e.message
        # ignore errors
        raise if Rails.env.test?
      end
    end
  end

  def load_mxit_user
    if request.env['HTTP_X_MXIT_USERID_R']
      @current_user = User.find_or_create_from_auth_hash(provider: 'mxit',
                                                              uid: request.env['HTTP_X_MXIT_USERID_R'],
                                                             info: { name: request.env['HTTP_X_MXIT_NICK']})
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

  def load_facebook_user
    if params[:signed_request]
      encoded_sig, payload = params[:signed_request].split('.')
      encoded_str = payload.gsub('-','+').gsub('_','/')
      encoded_str += '=' while !(encoded_str.size % 4).zero?
      @data = ActiveSupport::JSON.decode(Base64.decode64(encoded_str))
      if @data.kind_of?(Hash) && @data['user_id']
        self.current_user = User.find_or_create_from_auth_hash(provider: 'facebook_canvas',
                                                                    uid: @data['user_id'],
                                                                  info: { name: "user #{@data['user_id']}"})
      else
        redirect_to facebook_oauth_path
        false
      end
    end
  end

  private

  def tracking_enabled?
    !ENV['GA_TRACKING_CODE'].blank?
  end

  def tracking_code
    ENV['GA_TRACKING_CODE']
  end

end

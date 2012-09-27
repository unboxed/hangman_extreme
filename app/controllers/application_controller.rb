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
      if request.env['HTTP_X_DEVICE_USER_AGENT']
        g.user_agent = "Mxit #{request.env['HTTP_X_DEVICE_USER_AGENT']}"
      elsif request.env['HTTP_USER_AGENT']
        g.user_agent = request.env['HTTP_USER_AGENT']
      end
      if request.env["HTTP_X_MXIT_PROFILE"]
        profile = MxitProfile.new(request.env["HTTP_X_MXIT_PROFILE"])
        g.utmul = profile.language
        g.set_custom_var(1, 'Gender', profile.gender, 1)
        g.set_custom_var(2, 'Age', profile.age.to_s, 1)
      end
      if request.env["HTTP_X_MXIT_LOCATION"]
        location = MxitLocation.new(request.env["HTTP_X_MXIT_LOCATION"])
        g.set_custom_var(3, location.country_name, location.principal_subdivision_name, 1)
      end
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
      end
      if request.env['HTTP_X_DEVICE_USER_AGENT']
        @mxit_device = request.env['HTTP_X_DEVICE_USER_AGENT']
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

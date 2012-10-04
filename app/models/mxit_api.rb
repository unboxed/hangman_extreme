class MxitApi

  attr_reader :access_token, :token_type, :refresh_token, :scope, :expire_at
  def initialize(code, redirect_uri)
    body = nil
    RestClient.post('https://auth.mxit.com/token',
                    {:grant_type => 'authorization_code',
                     :code => code,
                     :redirect_uri => redirect_uri},
                    :accept => :json,
                    'Authorization' => "#{MxitApi.basic_auth}")  do |response, request, result|
      case response.code
        when 200
          body = response.body
        else
          message = {response: response.inspect, request: request.inspect, result: result.inspect}.inspect
          ENV['AIRBRAKE_API_KEY'].present? ? notify_airbrake(Exception.new(message)) : Rails.logger.error(message)
      end
    end
    if body
      data = ActiveSupport::JSON.decode(body)
      @access_token = data['access_token']
      @token_type = data['token_type']
      @refresh_token = data['refresh_token']
      @scope = data['scope']
      @expire_at = data['expires_in'].to_i.seconds.from_now
    end
  end

  def profile
    profile = {}
    body = nil
    RestClient.get('https://auth.mxit.com/user/profile',
                   :accept => :json,
                   :authorization => "#{token_type} #{access_token}") do |response, request, result|
      case response.code
        when 200
          body = response.body
        else
          message = {response: response.inspect, request: request.inspect, result: result.inspect}.inspect
          ENV['AIRBRAKE_API_KEY'].present? ? notify_airbrake(Exception.new(message)) : Rails.logger.error(message)
      end
    end
    if body
      data = ActiveSupport::JSON.decode(body)
      profile = Hash[data.map {|k, v| [k.underscore, v] }]
    end
    HashWithIndifferentAccess.new(profile)
  end

  def self.connect(code, redirect_uri)
    connection = new(code,redirect_uri)
    connection.access_token ? connection : nil
  end

  def self.basic_auth
    "Basic " + Base64.encode64("#{ENV['MXIT_CLIENT_ID']}:#{ENV['MXIT_CLIENT_SECRET']}")
  end

end
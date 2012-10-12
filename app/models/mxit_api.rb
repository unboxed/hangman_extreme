class MxitApi

  attr_reader :access_token, :token_type, :refresh_token, :scope, :expire_at
  def initialize(form_data = {grant_type: 'client_credentials', scope: 'message/send'})
    if form_data.kind_of?(Hash)
      url = URI.parse('https://auth.mxit.com/token')
      req = Net::HTTP::Post.new(url.path, 'Accept'=>'application/json')
      req.set_form_data(form_data)
      req.basic_auth(MxitApi.client_id, MxitApi.client_secret)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      response = http.request(req)
      if response.code == '200'
        data = ActiveSupport::JSON.decode(response.body)
        @access_token = data['access_token']
        @token_type = data['token_type']
        @refresh_token = data['refresh_token']
        @scope = data['scope']
        @expire_at = data['expires_in'].to_i.seconds.from_now
      end
    end
  end

  def profile
    profile = {}
    url = URI.parse('https://api.mxit.com/user/profile')
    req = Net::HTTP::Get.new(url.path, 'Authorization' => "#{token_type} #{access_token}", 'Accept'=>'application/json')
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    response = http.request(req)
    if response.code == '200'
      data = ActiveSupport::JSON.decode(response.body)
      profile = Hash[data.map {|k, v| [k.underscore, v] }]
    end
    HashWithIndifferentAccess.new(profile)
  end

  def send_message(params)
    begin
      params = Hash[params.map {|k, v| [k.to_s.camelize, v] }]
      params.reverse_merge!('Body' => 'Test', 'ContainsMarkup' => 'true', 'From' => ENV['MXIT_APP_NAME'] || 'hangman', 'SpoolTimeout' => 23.hours.to_i)
      url = URI.parse('https://api.mxit.com/message/send/')
      req = Net::HTTP::Post.new(url.path,
                                'Authorization' => "#{token_type} #{access_token}",
                                'Accept'=>'application/json',
                                'Content-Type' =>'application/json')
      req.body = params.to_json
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.request(req)
    rescue Exception => e
      ENV['AIRBRAKE_API_KEY'].present? ? notify_airbrake(e) : Rails.logger.error(e.message)
      raise if Rails.env.test?
    end
  end

  def self.connect(*args)
    connection = new(*args)
    connection.access_token ? connection : nil
  end

  def self.client_id
    ENV['MXIT_CLIENT_ID']
  end

  def self.client_secret
    ENV['MXIT_CLIENT_SECRET']
  end

end
require 'mxit_api'
class MxitApiWrapper

  attr_reader :connection
  delegate :access_token, :token_type, :refresh_token, :scope, :expire_at, to: :connection

  def initialize(form_data = {grant_type: 'client_credentials', scope: 'message/send'})
    @connection = MxitApi.new(self.class.client_id, self.class.client_secret, form_data)
  end

  def method_missing(m, *args, &block)
    connection.respond_to?(m) ? connection.send(m,*args,&block) : super(m, *args, &block)
  end

  def respond_to?(m, *args, &block)
    connection.respond_to?(m,*args, &block) || super(m, *args, &block)
  end

  def send_message(params)
    begin
      connection.send_message(params.reverse_merge(from: app_name, spool_timeout: 23.hours))
    rescue  => e
      Rails.logger.error(e.message)
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

  def app_name
    ENV['MXIT_APP_NAME']
  end

end

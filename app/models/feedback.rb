class Feedback

  def self.send_suggestion(options = {})
    begin
      client = UserVoice::Client.new(subdomain_name, api_key, api_secret)
      forum = client.get("/api/v1/forums.json")['forums'].first
      forum_id = forum['id']
      client.login_as(options[:email]) do |access_token|
        access_token.post("/api/v1/forums/#{forum_id}/suggestions.json", {
          :suggestion => {
            :title => options[:subject],
            :text => options[:message],
            :votes => 0
          }
        })
      end
    rescue Exception => e
      ENV['AIRBRAKE_API_KEY'].present? ? notify_airbrake(e) : Rails.logger.error(e.message)
      raise if Rails.env.test?
    end
  end

  def self.send_support(options = {})
    begin
      client = UserVoice::Client.new(subdomain_name, api_key, api_secret)
      client.post("/api/v1/tickets.json", {
        :email => options[:email],
        :ticket => {
          :subject => options[:subject],
          :message => options[:message]
        }
      })
    rescue Exception => e
      ENV['AIRBRAKE_API_KEY'].present? ? notify_airbrake(e) : Rails.logger.error(e.message)
      raise if Rails.env.test?
    end
  end

  private

  def self.subdomain_name
    ENV['UV_SUBDOMAIN_NAME']
  end

  def self.api_key
    ENV['UV_API_KEY']
  end

  def self.api_secret
    ENV['UV_API_SECRET']
  end

end
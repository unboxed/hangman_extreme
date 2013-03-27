class Feedback

  cattr_accessor :subdomain_name, :api_key, :api_secret

  def self.send_suggestion(options = {})
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
  end

  def self.send_support(options = {})
    client = UserVoice::Client.new(subdomain_name, api_key, api_secret)
    client.post("/api/v1/tickets.json", {
      :email => options[:email],
      :name => options[:name],
      :ticket => {
        :subject => options[:subject],
        :message => options[:message]
      }
    })
  end

end

Feedback.subdomain_name = ENV['UV_SUBDOMAIN_NAME']
Feedback.api_key = ENV['UV_API_KEY'] || ''
Feedback.api_secret = ENV['UV_API_SECRET']  || ''
class MyTokenAuthentication < Faraday::Middleware
  def call(env)
    env[:request_headers]["X-API-Token"] = ENV['USER_ACCOUNT_API_KEY'].to_s
    @app.call(env).on_complete do
      # do something with the response
    end
  end
end

# config/initializers/her.rb
Her::API.setup url: ENV['USER_ACCOUNT_API'] do |c|
  # Request
  c.use MyTokenAuthentication
  c.use Faraday::Request::UrlEncoded

  # Response
  c.use Her::Middleware::DefaultParseJSON

  # Adapter
  c.use Faraday::Adapter::NetHttp
end

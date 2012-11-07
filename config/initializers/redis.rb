if ENV["REDISTOGO_URL"]
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  REDIS = Redis.new(:host => 'localhost', :port => 6379)
end
Redis.current = REDIS

Redis::Settings.configure do |config|
  config.connection = Redis.current
end
APP_SETTINGS = Redis::Settings.new("app")

class Redis
  def self.connect(options = {})
    current
  end
end
Ohm.connect

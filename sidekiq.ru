# This file is used by Rack-based servers to start the application.
require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = { :url => ENV['SIDEKIQ_REDIS_URL'], :namespace => 'sidekiq' }
end

require 'sidekiq/web'

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == ENV['SIDEKIQ_USERNAME'] && password == ENV['SIDEKIQ_PASSWORD']
end

run Sidekiq::Web
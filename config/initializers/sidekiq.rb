require 'sidekiq'
Sidekiq.configure_server do |config|
  config.redis = { :url => ENV['SIDEKIQ_REDIS_URL'], :namespace => 'sidekiq' }
end

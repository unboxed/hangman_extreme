require 'sidekiq'
redis_options = { :url => ENV['SIDEKIQ_REDIS_URL'], :namespace => 'sidekiq' }
redis_options[:size] = ENV['SIDEKIQ_SIZE'].to_i if ENV['SIDEKIQ_SIZE'].present?
Sidekiq.configure_server do |config|
  config.redis = redis_options
end
Sidekiq.configure_client do |config|
  config.redis = redis_options
end

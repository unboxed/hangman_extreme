require 'airbrake/rake_handler' if defined?(Rake::Module)

Airbrake.configure do |config|
  config.api_key = ENV['AIRBRAKE_API_KEY'] if ENV['AIRBRAKE_API_KEY'].present?
  config.environment_name = ENV['AIRBRAKE_ENV_NAME'] if ENV['AIRBRAKE_ENV_NAME'].present?
  config.host = ENV['AIRBRAKE_HOST'] if ENV['AIRBRAKE_HOST']
  config.rescue_rake_exceptions = true if defined?(Rake::Module)
end



Airbrake.configure do |config|
  config.api_key = ENV['AIRBRAKE_API_KEY']
  config.environment_name = ENV['AIRBRAKE_ENV_NAME'] if ENV['AIRBRAKE_ENV_NAME'].present?
  config.rescue_rake_exceptions = true
end if ENV['AIRBRAKE_API_KEY'].present?



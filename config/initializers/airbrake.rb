Airbrake.configure do |config|
  config.api_key = ENV['AIRBRAKE_API_KEY'] || '153f0678e4adcb5855b919b0118278e7'
  config.environment_name = ENV['AIRBRAKE_ENV_NAME'] if ENV['AIRBRAKE_ENV_NAME'].present?
  config.rescue_rake_exceptions = true
end if ENV['AIRBRAKE_API_KEY'].present?



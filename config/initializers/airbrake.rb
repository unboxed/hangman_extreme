Airbrake.configure do |config|
  config.api_key = ENV['AIRBRAKE_API_KEY']
end if ENV['AIRBRAKE_API_KEY'].present?


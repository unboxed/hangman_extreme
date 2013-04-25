Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer, :fields => [:name, :email]
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], scope: 'email,user_birthday,user_location,user_hometown'
end

OmniAuth.config.logger = Rails.logger
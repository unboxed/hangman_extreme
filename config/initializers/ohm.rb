Ohm.redis = Redic.new(ENV['REDIS_URL']) if ENV['REDIS_URL']
#Ohm.connect :thread_safe => Rails.env.production?

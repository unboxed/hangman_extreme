require 'librato/metrics'
Librato::Metrics.authenticate(ENV['LIBRATO_EMAIL'], ENV['LIBRATO_API_KEY'])

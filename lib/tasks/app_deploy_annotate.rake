namespace :app do

  namespace :deploy do

    desc "annotate deployment on librato"
    task :annotate => :environment do
      Librato::Metrics.authenticate(ENV['LIBRATO_EMAIL'], ENV['LIBRATO_API_KEY'])
      Librato::Metrics.annotate :deployment, ENV['REVISION']
    end
  end

end
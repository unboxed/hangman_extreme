namespace :app do

  namespace :deploy do

    desc "annotate deployment on librato"
    task :annotate => :environment do
      Librato::Metrics.authenticate(ENV['LIBRATO_EMAIL'], ENV['522f32c9b4fc6a1e7efca4c0cb7391caa40583242a67e5428fc771226ff4503b'])
      Librato::Metrics.annotate :deployment, ENV['REVISION']
    end
  end

end
default_run_options[:pty] = true # Must be set for the password prompt

set :application, "hangman_extreme"
set :repository, "git@github.com:unboxed/hangman_extreme.git"

set :scm, :git
set :user, :rails

role :web, "41.215.236.134" # Your HTTP server, Apache/etc
role :app, "41.215.236.134" # This may be the same as your `Web` server
role :db, "41.215.236.134", :primary => true # This is where Rails migrations will run

after "deploy:restart", "deploy:cleanup"

set :rvm_ruby_string, 'jruby@hangman_extreme'
set :rvm_install_type, :head
set :rvm_type, :system
set :rvm_install_pkgs, %w[libyaml openssl]
set :rvm_install_ruby_params, '--with-opt-dir=/usr/local/rvm/usr'

require "rvm/capistrano" # Load RVM's capistrano plugin.
require "bundler/capistrano"
require 'airbrake/capistrano'

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

before 'deploy:setup', 'rvm:install_rvm'
before 'deploy:setup', 'rvm:install_ruby'

set :shared_children, shared_children << 'tmp/sockets'

namespace :db do

  desc <<-DESC
      Creates the database.yml configuration file in shared path.

      By default, this task uses a template unless a template
      called database.yml.erb is found either is :template_dir
      or /config/deploy folders. The default template matches
      the template for config/database.yml file shipped with Rails.

      When this recipe is loaded, db:setup is automatically configured
      to be invoked after deploy:setup. You can skip this task setting
      the variable :skip_db_setup to true. This is especially useful
      if you are using this recipe in combination with
      capistrano-ext/multistaging to avoid multiple db:setup calls
      when running deploy:setup for all stages one by one.
  DESC
  task :setup, :except => {:no_release => true} do

    template = <<-EOF
      base: &base
        adapter: postgresql
        timeout: 5000
      production:
        database: hangman_league
        <<: *base
    EOF

    config = ERB.new(template)

    run "mkdir -p #{shared_path}/db"
    run "mkdir -p #{shared_path}/config"
    put config.result(binding), "#{shared_path}/config/database.yml"
  end

  desc <<-DESC
      [internal] Updates the symlink for database.yml file to the just deployed release.
  DESC
  task :symlink, :except => {:no_release => true} do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/initializers/00_env.rb #{release_path}/config/initializers/00_env.rb"
  end

end

after "deploy:setup", "db:setup" unless fetch(:skip_db_setup, false)
after "deploy:finalize_update", "db:symlink"
after "deploy:finalize_update", "deploy:precompile_stylesheets"

set :shared_children, shared_children << 'tmp/sockets'

namespace :deploy do
  desc "compile stylesheets"
  task :precompile_stylesheets, :roles => :web, :except => {:no_release => true} do
    run "cd #{release_path} && RAILS_ENV=production bundle exec rake assets:precompile"
  end

  desc "Start the application"
  task :start, :roles => :app, :except => {:no_release => true} do
    run "cd #{current_path} && NEWRELIC_DISPATCHER=puma RAILS_ENV=production bundle exec puma -e production -t 8:32 -b tcp://41.215.236.134:8080 -S #{shared_path}/sockets/puma.state --control tcp://127.0.0.1:9293 >> #{shared_path}/log/puma-production.log 2>&1 &", :pty => false
  end

  desc "Stop the application"
  task :stop, :roles => :app, :except => {:no_release => true} do
    run "cd #{current_path} && NEWRELIC_DISPATCHER=puma RAILS_ENV=production bundle exec pumactl -S #{shared_path}/sockets/puma.state stop"
  end

  desc "Restart the application"
  task :restart, :roles => :app, :except => {:no_release => true} do
    run "cd #{current_path} && NEWRELIC_DISPATCHER=puma RAILS_ENV=production bundle exec pumactl -S #{shared_path}/sockets/puma.state restart"
  end

  desc "Status of the application"
  task :status, :roles => :app, :except => {:no_release => true} do
    run "cd #{current_path} && NEWRELIC_DISPATCHER=puma RAILS_ENV=production bundle exec pumactl -S #{shared_path}/sockets/puma.state stats"
  end
end


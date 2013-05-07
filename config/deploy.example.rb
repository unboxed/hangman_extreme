default_run_options[:pty] = true # Must be set for the password prompt
default_run_options[:shell] = 'bash --login'

ssh_options[:forward_agent] = true

set :rvm_ruby_string, 'jruby@user'
set :rvm_type, :user
require 'rvm/capistrano'
require 'airbrake/capistrano'
require "bundler/capistrano"
require 'puma/capistrano'
set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"
require 'new_relic/recipes'
require 'sidekiq/capistrano'

set :application, "hangman_extreme"
set :repository, "git@github.com:unboxed/hangman_extreme.git"

set :scm, :git
# set :user, 'user'
set :use_sudo, false
# set :deploy_to, '/home/user'

role :web, "" # Your HTTP server, Apache/etc
role :app, "" # This may be the same as your `Web` server
role :db, "", :primary => true # This is where Rails migrations will run

set :shared_children, shared_children + ['tmp/sockets']

after "deploy:restart", "deploy:cleanup"
after "deploy:finalize_update", "app:symlink"
after "deploy:finalize_update", "deploy:precompile_stylesheets"
after "deploy", "librato:deploy"
# after "deploy:update", "newrelic:notice_deployment"

before 'deploy:setup', 'rvm:install_rvm'   # install RVM
before 'deploy:setup', 'rvm:install_ruby'  # install Ruby and create gemset, or:
before 'deploy:setup', 'rvm:create_gemset' # only create gemset
after "deploy:setup", "app:setup"
after "app:setup", "app:upload_appenv"

# before 'deploy:migrate', 'app:createdb'

namespace :app do

  #desc "Create the database"
  #task :createdb, :except => {:no_release => true} do
  #  run "cd #{release_path} && bundle exec rake RAILS_ENV=production db:create; true"
  #end

  desc "upload database.yml"
  task :setup, :except => {:no_release => true} do
    # upload "config/appenv", "#{deploy_to}/appenv", :via => :scp
    # run "cat #{deploy_to}/appenv >> #{deploy_to}/.bash_profile"
    upload "config/database.yml", "#{shared_path}/database.yml", :via => :scp
    run "rvm --default use #{rvm_ruby_string}"
  end

  desc "load appenv"
  task :upload_appenv, :except => {:no_release => true} do
    upload "config/appenv", "#{deploy_to}/appenv", :via => :scp
  end

  desc "Updates the symlink for database.yml file to the just deployed release."
  task :symlink, :except => {:no_release => true} do
    run "ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml"
    upload "./db/words.csv", "#{release_path}/db/words.csv", :via => :scp
  end

end

namespace :deploy do

  desc "compile stylesheets"
  task :precompile_stylesheets, :roles => :web, :except => {:no_release => true} do
    run "cd #{release_path} && RAILS_ENV=production bundle exec rake assets:precompile"
  end

end

namespace :librato do

  desc "annotate deployment on librato"
  task :deploy, :except => {:no_release => true} do
    run "cd #{release_path} && RAILS_ENV=production REVISION=#{current_revision} bundle exec rake app:deploy:annotate"
  end

end

namespace :pull do

  desc "annotate deployment on librato"
  task :logs, :except => {:no_release => true} do
    download "#{shared_path}/log/production.log", "log/production.log", :via => :scp
    download "#{shared_path}/log/puma.log", "log/puma.log", :via => :scp
    download "#{shared_path}/log/twopuma.log", "log/twopuma.log", :via => :scp
    download "#{shared_path}/log/cron_log.log", "log/cron_log.log", :via => :scp
  end

  desc "Download schema.rb"
  task :schema, :roles => :db do
    "cd #{current_path};RAILS_ENV=production bundle exec db:schema:dump"
    download "#{current_path}/db/schema.rb", "db/schema.rb"
  end

end

after 'puma:force_start', 'puma:start'


namespace :puma do
  desc 'Force start puma'
  task :force_start, :roles => lambda { fetch(:puma_role) }, :on_no_matching_servers => :continue do
    run "cd #{current_path} && #{fetch(:pumactl_cmd)} -S #{fetch(:puma_state)} stop; true"
    run "rm -f #{shared_path}/sockets/puma*"
  end

  desc 'Start puma'
  task :start, :roles => lambda { fetch(:puma_role) }, :on_no_matching_servers => :continue do
    puma_env = fetch(:rack_env, fetch(:rails_env, 'production'))
    run "cd #{current_path} && nohup #{fetch(:puma_cmd)} -q -t 4:32 -e #{puma_env} -b 'tcp://0.0.0.0:9292' -S #{fetch(:puma_state)} --control 'unix://#{shared_path}/sockets/pumactl.sock' >> #{shared_path}/log/puma.log 2>&1 &", :pty => false
  end

  desc 'Stop puma'
  task :stop, :roles => lambda { fetch(:puma_role) }, :on_no_matching_servers => :continue do
    run "cd #{current_path} && #{fetch(:pumactl_cmd)} -S #{fetch(:puma_state)} stop"
  end

  desc 'Restart puma'
  task :restart, :roles => lambda { fetch(:puma_role) }, :on_no_matching_servers => :continue do
    run "cd #{current_path} && #{fetch(:pumactl_cmd)} -S #{fetch(:puma_state)} restart"
  end
end

after 'deploy:stop', 'twopuma:stop'
after 'deploy:start', 'twopuma:start'
after 'deploy:restart', 'twopuma:restart'
after 'twopuma:force_start', 'twopuma:start'
_cset(:twopuma_state) { "#{shared_path}/sockets/twopuma.state" }

namespace :twopuma do
  desc 'Force start puma'
  task :force_start, :roles => lambda { fetch(:puma_role) }, :on_no_matching_servers => :continue do
    run "cd #{current_path} && #{fetch(:pumactl_cmd)} -S #{fetch(:twopuma_state)} stop; true"
    run "rm -f #{shared_path}/sockets/twopuma*"
  end

  desc 'Start puma'
  task :start, :roles => lambda { fetch(:puma_role) }, :on_no_matching_servers => :continue do
    puma_env = fetch(:rack_env, fetch(:rails_env, 'production'))
    run "cd #{current_path} && nohup #{fetch(:puma_cmd)} -q -t 4:32 -e #{puma_env} -b 'tcp://0.0.0.0:9293' -S #{fetch(:twopuma_state)} --control 'unix://#{shared_path}/sockets/twopumactl.sock' >> #{shared_path}/log/twopuma.log 2>&1 &", :pty => false
  end

  desc 'Stop puma'
  task :stop, :roles => lambda { fetch(:puma_role) }, :on_no_matching_servers => :continue do
    run "cd #{current_path} && #{fetch(:pumactl_cmd)} -S #{fetch(:twopuma_state)} stop"
  end

  desc 'Restart puma'
  task :restart, :roles => lambda { fetch(:puma_role) }, :on_no_matching_servers => :continue do
    run "cd #{current_path} && #{fetch(:pumactl_cmd)} -S #{fetch(:twopuma_state)} restart"
  end
end

namespace :sidekiq do

  desc 'start server'
  task :web_server, :roles => lambda { fetch(:puma_role) }, :on_no_matching_servers => :continue do
    run "cd #{current_path} && bundle exec puma sidekiq.ru -b 'tcp://0.0.0.0:8080'"
    run "rm -f #{shared_path}/sockets/twopuma*"
  end

end

namespace :rails do
  desc "Remote console"
  task :console, :roles => :db do
    run_interactively "cd #{current_path};script/rails console production"
  end

  desc "Remote dbconsole"
  task :dbconsole, :roles => :db do
    run_interactively "cd #{current_path};script/rails dbconsole production"
  end

end

def run_interactively(command, server=nil)
  server ||= find_servers_for_task(current_task).first
  exec %Q(ssh #{user}@#{server.host} -t 'bash --login -c "cd #{current_path} && #{command}"')
end
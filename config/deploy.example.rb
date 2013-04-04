require 'rvm/capistrano'
require 'airbrake/capistrano'
require "bundler/capistrano"
require 'puma/capistrano'
require 'new_relic/recipes'
default_run_options[:pty] = true # Must be set for the password prompt
default_run_options[:shell] = 'bash --login'

ssh_options[:forward_agent] = true

set :rvm_ruby_string, 'jruby@hmx'
set :rvm_install_ruby_params, '--1.9'      # for jruby/rbx default to 1.9 mode
set :rvm_type, :user

set :application, "hangman_extreme"
set :repository, "git@github.com:unboxed/hangman_extreme.git"

set :scm, :git
set :user, 'hmx'
set :use_sudo, false
set :deploy_to, '/home/hmx'

role :web, "" # Your HTTP server, Apache/etc
role :app, "" # This may be the same as your `Web` server
role :db, "", :primary => true # This is where Rails migrations will run

set :shared_children, shared_children << 'tmp/sockets'

after "deploy:restart", "deploy:cleanup"
after "deploy:finalize_update", "app:symlink"
                                 # after "deploy:finalize_update", "deploy:precompile_stylesheets"
after "deploy", "librato:deploy"
after "deploy", "rvm:trust_rvmrc"
after "deploy:update", "newrelic:notice_deployment"

before 'deploy:setup', 'rvm:install_rvm'   # install RVM
before 'deploy:setup', 'rvm:install_ruby'  # install Ruby and create gemset, or:
before 'deploy:setup', 'rvm:create_gemset' # only create gemset
after "deploy:setup", "app:setup"

namespace :app do

  desc "Creates the database.yml configuration file in shared path."
  task :setup, :except => {:no_release => true} do
    run "rvm default #{rvm_ruby_string} && rvm use #{rvm_ruby_string} && gem install bundler"
    run "rm -f #{deploy_to}/.bashrc"
    upload "config/deploy_bashrc", "#{deploy_to}/.bashrc", :via => :scp
    upload "config/database.yml", "#{shared_path}/database.yml", :via => :scp
  end

  desc <<-DESC
      [internal] Updates the symlink for database.yml file to the just deployed release.
  DESC
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

namespace :puma do
  desc 'Start puma'
  task :start, :roles => lambda { fetch(:puma_role) }, :on_no_matching_servers => :continue do
    puma_env = fetch(:rack_env, fetch(:rails_env, 'production'))
    run "cd #{current_path} && #{fetch(:puma_cmd)} -q -d -t 8:32 -e #{puma_env} -b 'tcp://0.0.0.0:9292' -S #{fetch(:puma_state)} --control 'unix://#{shared_path}/sockets/pumactl.sock'", :pty => false
  end
end

namespace :rails do
  desc "Remote console"
  task :console, :roles => :db do
    run_interactively "cd #{current_path};#{jruby_bin} script/rails console production"
  end

  desc "Remote dbconsole"
  task :dbconsole, :roles => :db do
    run_interactively "cd #{current_path};#{jruby_bin} script/rails dbconsole production"
  end

  desc "Download schema.rb"
  task :download_schema, :roles => :db do
    "cd #{current_path};RAILS_ENV=production bundle exec db:schema:dump"
    download "#{current_path}/db/schema.rb", "db/schema.rb"
  end

end

namespace :rvm do
  task :trust_rvmrc do
    run "rvm rvmrc trust #{release_path}"
  end
end

namespace :ec2 do
  task :get_public_key do
    host = find_servers_for_task(current_task).last.host
    privkey = ssh_options[:keys][0]
    pubkey = "#{privkey}.pub"
    `scp -i '#{privkey}' ec2-user@#{host}:.ssh/authorized_keys #{pubkey}`
  end
end

def run_interactively(command, server=nil)
  server ||= find_servers_for_task(current_task).first
  exec %Q(ssh #{user}@#{server.host} -t 'bash --login -c "cd #{current_path} && #{command}"')
end


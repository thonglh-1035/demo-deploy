# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

# Tên application của mình
set :application, 'demo-deploy' 
# Repository github của bạn. Tạo 1 repo mới trên github
set :repo_url, 'git@github.com:thonglh-1035/demo-deploy.git' 
set :branch, :master
set :deploy_to, "/home/ec2-user/rails_app/#{fetch :application}"
set :pty, true
set :linked_files, %w{config/database.yml config/application.yml config/master.key config/credentials.yml.enc}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads}
set :keep_releases, 5
set :rvm_type, :user
set :rvm_ruby_version, 'ruby-2.4.1' 

set :puma_rackup, -> { File.join(current_path, 'config.ru') }
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"    #accept array for multi-bind
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma_error.log"
set :puma_error_log, "#{shared_path}/log/puma_access.log"
set :puma_role, :app
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [0, 8]
set :puma_workers, 1
set :puma_worker_timeout, nil
set :puma_init_active_record, true
set :puma_preload_app, false


# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

namespace :deploy do
  before :migrate, :create_database

  desc "create database"
  task :create_database do
    on roles(:db) do |host|
      within "#{release_path}" do
        with rails_env: ENV["RAILS_ENV"] do
          execute :rake, "db:create"
        end
      end
    end
  end

  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        execute "/bin/bash #{ENV["APP_ROOT"]}/config/deploy/common/puma.sh"
      end
    end
  end
  # after :link_env, :create_database

  # desc 'Restart application'
  # task :restart do
  #   on roles(:app), in: :sequence, wait: 5 do
  #     within release_path do
  #       if test "[ -f #{fetch(:puma_pid)} ]" and test :kill, "-0 $( cat #{fetch(:puma_pid)} )"
  #         execute "echo $PATH"
  #         execute "which pumactl"
  #         execute "pumactl -S #{fetch(:puma_state)} restart"
  #       else
  #         execute "sudo service puma start"
  #       end
  #     end
  #   end

  #   on roles(:worker), in: :sequence, wait: 5 do
  #     within release_path do
  #       execute "sudo service sidekiq restart"
  #     end
  #   end
  # end

  # after :publishing, :restart

  # desc "update ec2 tags"
  # task :update_ec2_tags do
  #   on roles(:app) do
  #     within "#{release_path}" do
  #       branch = fetch(:branch)
  #       ref_type = fetch(:deploy_ref_type)
  #       last_commit = fetch(:current_revision)
  #       update_ec2_tags ref_type, branch, last_commit
  #     end
  #   end
  # end
  # after :restart, :update_ec2_tags
end

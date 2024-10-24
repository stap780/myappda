lock "~> 3.19.1"

server "178.253.40.249", port: 22, roles: [:web, :app, :db], primary: true
set :application, "myappda"
set :repo_url, "git@github.com:stap780/myappda.git"

set :user, "myappda"
set :puma_threads, [4, 16]
set :puma_workers, 0

set :pty, true
set :use_sudo, true
set :sudo, "sudo -u myappda -i"
set :stage, :production
set :deploy_via, :remote_cache
set :deploy_to, "/var/www/#{fetch(:application)}"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log, "#{release_path}/log/puma.error.log"
set :ssh_options, {forward_agent: true, user: fetch(:user), keys: %w[~/.ssh/id_rsa.pub]}
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

append :linked_files, "config/master.key", "config/database.yml", "config/sidekiq.yml", "config/sidekiq_scheduler.yml"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "public", "tmp/sockets", "vendor/bundle", "lib/tasks", "lib/drop", "storage"

namespace :puma do
  desc "Create Directories for Puma Pids and Socket"
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before "deploy:starting", "puma:make_dirs"
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      # Update this to your branch name: master, main, etc. Here it's master
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/main"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc "Initial Deploy"
  task :initial do
    on roles(:app) do
      before "deploy:restart", "puma:start"
      invoke "deploy"
    end
  end

  desc "Restart application"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke "puma:restart"
    end
  end

  namespace :sidekiq do
    desc "Restart Sidekiq"
    task :restart do
      on roles(:app) do
        execute :sudo, :systemctl, :restart, :sidekiq
        execute :sudo, :systemctl, "daemon-reload"
      end
    end
  end

  before :starting, :check_revision
  after :finishing, :compile_assets
  after :finishing, :cleanup
  # sidekiq related commands
  after "deploy:published", "sidekiq:restart"
end

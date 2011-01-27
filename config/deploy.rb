require "bundler/capistrano"

set :application,  "issuemap"
set :scm,          "git"
set :repository,   "git@github.com:fortiusone/issuemap.git"
set :git_enable_submodules, 1
set :deploy_via,   :remote_cache
set :use_sudo,     false
set :runner,       "issuemap"
set :admin_runner, "issuemap"
set :ssh_options,  { :forward_agent => true }

task :qa do
  set :rails_env,   "qa"
  set :branch,      "master"
  set :deploy_to,   "/fortiusone/live/apps/#{application}"
  server "captest@issue-test.geoiq.com", :web, :app, :db, :primary => true
end

after "deploy:symlink", "deploy:symlink_configs"
after "deploy:symlink", "deploy:update_stylesheets"
after "deploy:restart", "deploy:cleanup"

namespace :deploy do
  desc "Long deploy will throw up the maintenance.html page and run migrations then it restarts and enables the site again."
  task :long do
    transaction do
      update_code
      web.disable
      symlink
      migrate
    end

    restart
    web.enable
  end

  task :symlink_configs, :roles => :app, :except => {:no_symlink => true} do
    run <<-CMD
      ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
      ln -nfs #{shared_path}/config/config.yml   #{release_path}/config/config.yml
    CMD
  end

  task :update_stylesheets, :roles => :app do
    run "#{current_path}/script/runner -e #{rails_env} \"Sass::Plugin.options = { :always_update => true }; Sass::Plugin.update_stylesheets;\""
  end

  desc "Tail the Rails log for this environment"
  task :logs, :roles => :app do
    stream "tail -f #{shared_path}/log/#{rails_env}.log"
  end

  desc "Restart the app server."
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

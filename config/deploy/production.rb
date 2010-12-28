set :stage, :qa

ssh_options[:compression] = false

set :user,  "root"
set :group, "root"

set :gateway, "ajturner@babylon"
# set :hostname, "issuemap.org"
set :geoiq_server, "http://geoiq.issuemapper.geoiq.com"
set :geoiq_user, "admin"
set :geoiq_password, "notpassword5"

set :s3_access_key_id, "0EY3EBN518T4EVVRVT82"
set :s3_secret_access_key, "4/wYhJ68jkzmyHrQST5SKq7worlL3GDep50Zno9P"
set :s3_bucket, "issuemap"

role :app, "issuemapper-alpha.geoiq.com", "issuemapper-beta.geoiq.com"
role :web, "issuemapper-alpha.geoiq.com", "issuemapper-beta.geoiq.com"

set :deploy_environment, "production"
set :rails_env, "production"
set :branch, "master"
set :keep_releases, 3
after "deploy:update", "deploy:cleanup"
set :deploy_to,     "/fortiusone/live/apps/issuemapper"


ssh_options[:keys] = [File.join(ENV["HOME"], ".ec2-geocommons", "id_rsa")]

# after "deploy:update_code", "symlink", "set_permissions", 
before "deploy:restart", "geoiq:config", "deploy:s3_config", "symlink", "set_permissions"

desc "Sets group permissions on checkout."
task :set_permissions, :except => { :no_release => true } do
  run "chown -R nobody:nobody #{release_path}"
  run "chown -R nobody:nobody #{shared_path}"
  run "chmod g+rwx #{shared_path}"
end

desc "Re-establish staging database"
task :symlink do
  run <<-CMD
    ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml
  CMD
end
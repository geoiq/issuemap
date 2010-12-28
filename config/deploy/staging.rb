role :web, "ec2-72-44-48-158.compute-1.amazonaws.com"
role :app, "ec2-72-44-48-158.compute-1.amazonaws.com"
role :db, "ec2-72-44-48-158.compute-1.amazonaws.com"

after "deploy:update_code", "symlink", "permissions", "symlink_db"
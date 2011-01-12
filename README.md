# Getting Started

Initialize the config files, and edit them as necessary

    $ cp config/database.yml.example config/database.yml
    $ cp config/config.yml.example config/config.yml

Initialize the database

    $ rake db:setup

Initialize dependencies with bundler

    $ gem install bundler
    $ bundle install --path vendor
    $ bundle package

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

# Deploying

Make sure your public ssh key is both in the GitHub repository and under the
deployment server's user account.

Afterwards, run `bundle exec cap <environment> <task>`.  For example:

    $ bundle exec cap staging deploy:long

# Miscellaneous

The static error pages under public (404.html, 422.html, and 500.html) should
not be modified directly.  Instead, these static resources are generated from a
rake task.

    $ rake custom_errors:generate

To customize the output, see `PagesController#error_404`, `#error_422`, and `#error_500`

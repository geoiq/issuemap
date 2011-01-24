source "http://rubygems.org"

gem "rails", "2.3.10"

# The roo gem is a bit of a mess.  It doesn't handle its own dependencies
# correctly, but it parses XLS, XLSX, and Open Office spreadsheets.  In other
# words, we're stuck with it for now.
def load_roo_dependencies
  gem "rubyzip"
  gem "nokogiri"
  gem "spreadsheet"
  gem "google-spreadsheet-ruby", :require => "google_spreadsheet"
end

gem "roo"; load_roo_dependencies
gem "pg"
gem "httparty"
gem "haml"
gem "maruku"
gem "compass"
gem "fancy-buttons"

group :development do
  gem "sqlite3-ruby"
end

group :test do
  gem "shoulda"
  gem "factory_girl"
  gem "timecop"
  gem "fakeweb"
  gem "mocha"
  gem "no_peeping_toms"
  gem "mynyml-redgreen", :require => "redgreen"
  gem "autotest"
  gem "autotest-rails"
  gem "autotest-fsevent"
  gem "autotest-growl"
end


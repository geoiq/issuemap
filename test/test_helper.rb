ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
end

Shoulda.autoload_macros Rails.root.to_s
Factory.find_definitions
FakeWeb.allow_net_connect = false
Mocha::Configuration.warn_when(:stubbing_non_existent_method)
Mocha::Configuration.warn_when(:stubbing_non_public_method)
ActiveRecord::Observer.disable_observers

# Unfortunately, Rack::Test:UploadedFile does not quack like
# ActionDispatch::Http::UploadedFile
class Rack::Test::UploadedFile
  attr_reader :tempfile
end

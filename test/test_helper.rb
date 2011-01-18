ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end

FakeWeb.allow_net_connect = false
Mocha::Configuration.warn_when(:stubbing_non_existent_method)
Mocha::Configuration.warn_when(:stubbing_non_public_method)

class Test::Unit::TestCase
  def fixture_file(filename, content_type = "application/octet-stream")
    ActionController::TestUploadedFile.new(Rails.root.join("test", "fixtures", "files", filename).to_s, content_type)
  end

  def fixture_file_contents(filename)
    Rails.root.join("test", "fixtures", "files", filename).read
  end
end

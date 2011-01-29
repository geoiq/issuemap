namespace :custom_errors do
  desc "Re-generate static custom error pages under the public directory"
  task :generate => :environment do
    page = PageFetcher.new
    %w(500 422 404).each do |code|
      filename = File.join(Rails.public_path, "#{code}.html")
      File.open(filename, "w") do |f|
        puts "Generating #{filename}..."
        f.write page.fetch("error_#{code}")
      end
    end
  end
end

require "action_controller/test_case"
# This simulates a request so that we can fetch the contents of a page response.
class PageFetcher
  def initialize
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @controller = PagesController.new
    @routes = Rails.application.routes
    @controller.request = @request
    @controller.params = {}
    extend ActionController::TestCase::Behavior
  end

  def fetch(action)
    get action
    @response.body
  end
end

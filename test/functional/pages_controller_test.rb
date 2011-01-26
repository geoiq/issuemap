require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  def self.should_get_page(page, path = "/pages/#{page}", template = page)
    should route(:get, path).to(:action => page, :controller => "pages")
    context "A page request for #{page}" do
      setup { get page }
      should respond_with :success
      should render_template template
    end
  end

  should "route the root path to the home action" do
    assert_recognizes({ :controller => "pages", :action => "home" }, "/")
  end

  should_get_page :home
  should_get_page :privacy
  should_get_page :tos
  should_get_page :faq
  should_get_page :usage

  on_get :home do
    should assign_to :maps
  end
end

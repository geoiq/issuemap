require 'test_helper'

class MapsControllerTest < ActionController::TestCase
  should route(:get, "/maps/new").to(:action => :new)
  should route(:post, "/maps").to(:action => :create)
  should route(:put, "/maps/1").to(:action => :update, :id => 1)
  should route(:get, "/maps/review").to(:action => :review)

  context "on GET to :new" do
    setup { get :new }

    should assign_to :map
    should_not set_the_flash
    should render_template :new
    should respond_with :success
  end
end

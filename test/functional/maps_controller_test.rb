require 'test_helper'

class MapsControllerTest < ActionController::TestCase
  should route(:get,  "/maps/new").to(:action => :new)
  should route(:post, "/maps").to(:action => :create)
  should route(:put,  "/maps/1").to(:action => :update, :id => 1)
  should route(:post, "/maps/new/preprocess").to(:action => :preprocess)

  on_get :new do
    should assign_to :map
    should_not set_the_flash
    should render_template :new
    should respond_with :success
  end

  # Testing uploaded data
  on_post :preprocess, lambda {{ :data => fixture_file("commas.csv", "text/csv") }}  do
    should_not set_the_flash
    should respond_with :success
    # Even though the response content is json, we need to specify text/html,
    # because we're submitting the data back in a hidden iframe.  This allows us
    # to handle ajaxified file uploads, but also get data back.
    should respond_with_content_type("text/html")
  end

  # Testing pasted data
  on_post :preprocess, lambda {{ :data => fixture_file("commas.csv", "text/csv").read }}  do
    should_not set_the_flash
    should respond_with :success
    should respond_with_content_type("text/html")
  end

  on_post :preprocess do
    should respond_with :error
    should respond_with_content_type("text/html")
  end
end


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

  context "Given a map" do
    setup { @map = Factory(:map) }

    on_get :show, lambda {{ :id => @map.to_param }} do
      should respond_with :success
    end

    on_get :show, lambda {{ :id => "#{@map.token}-some-outdated-or-wrong-slug" }} do
      should redirect_to("correct map path") { @map }
    end

    context "" do
      setup do
        Map.any_instance.expects(:to_png).with(:text => map_url(@map.token)).returns("png-bytes")
      end

      on_get :show, lambda {{ :id => @map.to_param, :format => "png" }} do
        should respond_with :success
        should respond_with_content_type "image/png"
        should "respond with a png" do
          assert_equal "png-bytes", @response.body
        end
      end
    end

    context "" do
      setup do
        Map.any_instance.expects(:to_csv).returns("csv-data")
      end

      on_get :show, lambda {{ :id => @map.to_param, :format => "csv" }} do
        should respond_with :success
        should respond_with_content_type "text/csv"
        should "respond with a csv" do
          assert_equal "csv-data", @response.body
        end
      end
    end

    context "" do
      setup do
        Map.any_instance.expects(:to_kml).returns("kml-data")
      end

      on_get :show, lambda {{ :id => @map.to_param, :format => "kml" }} do
        should respond_with :success
        should respond_with_content_type "application/vnd.google-earth.kml+xml"
        should "respond with a kml" do
          assert_equal "kml-data", @response.body
        end
      end
    end
  end
end


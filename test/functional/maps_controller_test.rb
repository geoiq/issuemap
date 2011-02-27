require 'test_helper'

class MapsControllerTest < ActionController::TestCase
  should route(:get,  "/maps/new").to(:action => :new)
  should route(:post, "/maps").to(:action => :create)
  should route(:put,  "/maps/1").to(:action => :update, :id => 1)
  should route(:post, "/maps/new/preprocess").to(:action => :preprocess)
  should route(:get,  "/maps/1").to(:action => :show, :id => 1)
  should route(:get,  "/map_cache/1.png").to(:controller => :maps, :action => :cache, :id => 1, :format => :png)

  on_get :new do
    should assign_to :map
    should_not set_the_flash
    should render_template :new
    should respond_with :success

    should "have all the necessary file import form fields" do
      assert_form(preprocess_new_map_path, :post, 2) do
        assert_select "input[type=file][name=?]", "data"
      end
    end

    should "have all the necessary paste import form fields" do
      assert_form(preprocess_new_map_path, :post, 2) do
        assert_select "textarea[name=?]", "data"
      end
    end

    should "have all the necessary submission form fields" do
      assert_form(maps_path, :post) do
        assert_hidden_field :map, :original_csv_data
        assert_label        :map, :location_column_name
        assert_drop_down    :map, :location_column_name, :location_column_type
        assert_label        :map, :data_column_name
        assert_drop_down    :map, :data_column_name, :data_column_type
        assert_label        :map, :title
        assert_text_field   :map, :title
        assert_submit
      end
    end
  end

  # Testing uploaded data
  on_post :preprocess, lambda {{ :data => fixture_file_upload("/files/commas.csv", "text/csv") }}  do
    should_not set_the_flash
    should respond_with :success
    # Even though the response content is json, we need to specify text/html,
    # because we're submitting the data back in a hidden iframe.  This allows us
    # to handle ajaxified file uploads, but also get data back.
    should respond_with_content_type("text/html")
  end

  # Testing pasted data
  on_post :preprocess, lambda {{ :data => fixture_file_upload("/files/commas.csv", "text/csv").read }}  do
    should_not set_the_flash
    should respond_with :success
    should respond_with_content_type("text/html")
  end

  on_post :preprocess do
    should respond_with :error
    should respond_with_content_type("text/html")
  end

  on_post :create, :map => Factory.attributes_for(:map) do
    should assign_to :map
    should set_session(:owned_maps).to { [assigns(:map).id] }
    should redirect_to("new map page") { map_path(assigns(:map).to_param) }
  end

  context "Given a session with a list of already owned maps" do
    setup { session[:owned_maps] = (1001..1012).to_a }

    on_post :create, :map => Factory.attributes_for(:map) do
      should "set an owned_maps session variable of length 10" do
        assert_equal 10, session[:owned_maps].length
      end

      should "set an owned_maps session variable containing the new map id" do
        assert session[:owned_maps].include?(assigns(:map).id)
      end
    end
  end

  context "Given a map" do
    setup { @map = Factory(:map) }

    on_get :show, lambda {{ :id => @map.to_param }} do
      should respond_with :success
      should_not set_session(:owned_maps).to { [@map.id] }

      should "respond with Open Graph meta tags" do
        assert_select "meta[name=og:site_name][content=?]", "IssueMap"
        assert_select "meta[name=og:title][content=?]",     "Title"
        assert_select "meta[name=og:url][content=?]",       map_url(@map.token)
        assert_select "meta[name=og:image][content=?]",     map_cache_url(@map.token, :format => "png")
      end
    end

    on_get :show, lambda {{ :id => @map.to_param, :admin_token => @map.admin_token }} do
      should set_session(:owned_maps).to { [@map.id] }
      should redirect_to("the public show page") { map_path(@map) }
    end

    on_get :show, lambda {{ :id => @map.to_param, :admin_token => "bogus token" }} do
      should_not set_session(:owned_maps)
      should redirect_to("the public show page") { map_path(@map) }
    end

    on_get :show, lambda {{ :id => "#{@map.token}-some-outdated-or-wrong-slug" }} do
      should redirect_to("correct map path") { @map }
    end

    context "fetching a png" do
      setup do
        Map.any_instance.expects(:to_png).with(:text => map_url(@map.token), :size => nil).returns("png-bytes")
      end

      on_get :show, lambda {{ :id => @map.to_param, :format => "png" }} do
        should respond_with :success
        should respond_with_content_type "image/png"
        should "respond with a png" do
          assert_equal "png-bytes", @response.body
        end
      end
    end

    context "fetching a small png" do
      setup do
        Map.any_instance.expects(:to_png).with(:text => map_url(@map.token), :size => "s").returns("png-bytes")
      end

      on_get :show, lambda {{ :id => @map.to_param, :format => "png", :size => "s" }} do
        should respond_with :success
        should respond_with_content_type "image/png"
        should "respond with a png" do
          assert_equal "png-bytes", @response.body
        end
      end
    end

    context "fetching a cached png" do
      setup do
        Map.any_instance.expects(:to_png).with(:text => map_url(@map.token), :size => "m").returns("png-bytes")
      end

      on_get :cache, lambda {{ :id => @map.to_param, :format => "png" }} do
        should respond_with :success
        should respond_with_content_type "image/png"
        should "respond with a png" do
          assert_equal "png-bytes", @response.body
        end
      end
    end

    context "fetching a csv" do
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

    context "fetching a kml" do
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

    context "and given a session owning that map" do
      setup { session[:owned_maps] = [@map.id] }

      on_put :update, lambda {{ :id => @map.to_param, :map => { :extent => "1,2,3,4", :color_palette => "diverging", :flip_colors => "1" } }} do
        should assign_to :map
        should redirect_to("map path") { @map }
      end
    end

    context "and given a session not owning that map" do
      setup { session[:owned_maps] = nil }

      on_put :update, lambda {{ :id => @map.to_param }} do
        should respond_with :unauthorized
      end
    end
  end
end


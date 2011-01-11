require 'spec_helper'

describe MapsController do
  it { should route(:get, '/maps/new').to(:action => :new) }
  it { should route(:post, '/maps').to(:action => :create) }
  it { should route(:put, '/maps/1').to(:action => :update, :id => 1) }
  it { should route(:get, '/maps/review').to(:action => :review) }

  context "GET to :new" do
    before(:each) do
      get :new
    end

    it { should respond_with(:success) }
    it { should render_template(:new) }
    it { should assign_to(:map) }
    it { should_not set_the_flash }
  end

  # context "GET to :verify" do
  #   context "when valid" do
  #     before(:each) do
  #       pending "MakerApi availability"
  #       post :verify, :map => { :dataset_attributes => { :data => "Name, Address, Latitude, Longitude\r\nChris, 1234 Main St Anytown US, -35.043985, 84.12034897" }}, :separator => ','
  #     end

  #     it { should respond_with(:success) }
  #     it { should render_template(:verify) }
  #     it { should assign_to(:map) }
  #     it { should_not set_the_flash }
  #   end

  #   context "when invalid" do
  #     before(:each) do
  #       pending "MakerApi availability"
  #       post :verify, :map => {}
  #     end

  #     it { should respond_with(:redirect) }
  #     it { should redirect_to(new_map_path) }
  #     it { should assign_to(:map) }
  #     it { should set_the_flash.to(/problem/i) }
  #   end
  # end

  # context "POST to :create" do
  #   before(:each) do
  #     @map = Factory.build(:map)

  #     geo_api = mock(:create_map_with_dataset => @map)
  #     GeoApi.stub!(:new).and_return(geo_api)

  #     @valid_params = {
  #       :map => @map.attributes.merge(:dataset_attributes => {
  #         :data_columns => ["data_column_one"],
  #         :location_columns => ["location_column_one"]
  #       })
  #     }
  #   end

  #   context "when valid" do
  #     before(:each) do
  #       post :create, @valid_params
  #     end

  #     it { should render_template(:create) }
  #     it { raise assigns(:map).errors.inspect }
  #   end

  #   context "when missing data column" do
  #     before(:each) do
  #       @error_message = "Please select at least one data column and at least one location column"
  #       post :create, @valid_params.tap { |h| h.delete(:data_columns) }
  #     end

  #     it "should set error flash" do
  #       # uses flash.now, so flash[:error] isn't available
  #       response.session["flash"][:error].should == @error_message
  #     end

  #     it { should render_template(:verify) }
  #   end

  #   context "when missing location column" do
  #     before(:each) do
  #       @error_message = "Please select at least one data column and at least one location column"
  #       post :create, @valid_params.tap { |h| h.delete(:location_columns) }
  #     end

  #     it "should set error flash" do
  #       # uses flash.now, so flash[:error] isn't available
  #       response.session["flash"][:error].should == @error_message
  #     end

  #     it { should render_template(:verify) }
  #   end
  # end
end


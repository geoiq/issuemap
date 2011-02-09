require 'test_helper'

class MapObserverTest < ActiveSupport::TestCase
  def setup
    ActiveRecord::Observer.enable_observers
  end

  def teardown
    ActiveRecord::Observer.disable_observers
  end

  context "A new Map" do
    setup { @map = Factory.build(:map) }

    context "on create" do
      setup do
        stub_geoiq_creation
        @map.save
      end

      before_should "have no geoiq associations" do
        assert @map.geoiq_dataset_xid.nil?
        assert @map.geoiq_map_xid.nil?
      end

      should "assign a geoiq dataset id to the map" do
        assert_equal "1", @map.geoiq_dataset_xid
      end

      should "assign a geoiq map id to the map" do
        assert_equal "2", @map.geoiq_map_xid
      end

      context "on subsequent save" do
        setup do
          stub_geoiq_update
          @map.title = "New Title"
          @map.extent = "4,3,2,1"
          @map.color_palette = "diverging"
          @map.save
        end

        should "leave the existing geoiq association alone" do
          @map.reload
          assert_equal "1", @map.geoiq_dataset_xid
          assert_equal "2", @map.geoiq_map_xid
        end
      end
    end
  end

  def stub_geoiq_creation
    dataset_stub = stub("dataset", :id => 1)
    map_stub     = stub("map",     :id => 2)

    MapStyles.expects(:random_color_palette).returns(:white_orange)
    styles = MapStyles.choropleth(:white_orange)
    styles[:fill][:selectedAttribute] = "b"

    layer_details = { :title => @map.title, :subtitle => "", :visible => true, :opacity => 1.0, :source => "finder:1", :styles => styles }
    dataset_details = { :data =>  "a,b\n1,2\n", :join_param => "column_types[a]", :join_value => "st" }
    map_details = { :title => @map.title, :basemap => @map.provider, :tags => "issuemap", :extent => "1,2,3,4", :layers => [layer_details] }

    GeoIQ.expects(:create_dataset).with(dataset_details).returns(dataset_stub)
    GeoIQ.expects(:get_dataset).with("1").returns(dataset_stub)
    GeoIQ.expects(:create_map).with(map_details).returns(map_stub)
    dataset_stub.expects(:[]).returns([1,2,3,4])
  end

  def stub_geoiq_update
    styles = MapStyles.choropleth(:diverging)
    styles[:fill][:selectedAttribute] = "b"

    layer_details = { :title => "New Title", :subtitle => "", :visible => true, :opacity => 1.0, :source => "finder:1", :styles => styles }
    map_details = { :title => "New Title", :basemap => @map.provider, :tags => "issuemap", :extent => "4,3,2,1", :layers => [layer_details] }

    GeoIQ.expects(:put).with("/maps/#{@map.geoiq_map_xid}.json", :query => map_details)
  end
end

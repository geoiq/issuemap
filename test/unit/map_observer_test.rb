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
        stub_geoiq
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
          @map.update_attribute(:title, "New Title")
        end

        should "leave the existing geoiq association alone" do
          @map.reload
          assert_equal "1", @map.geoiq_dataset_xid
          assert_equal "2", @map.geoiq_map_xid
        end
      end
    end
  end

  def stub_geoiq
    dataset_stub = stub("dataset", :id => 1)
    map_stub     = stub("map",     :id => 2)
    GeoIQ.expects(:create_dataset).returns(dataset_stub)
    GeoIQ.expects(:get_dataset).with("1").returns(dataset_stub)
    GeoIQ.expects(:create_map).returns(map_stub)
    map_stub.expects(:create_layer)
    dataset_stub.expects(:[]).returns([1,2,3,4])
  end
end

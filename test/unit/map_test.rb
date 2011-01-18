require 'test_helper'

class MapTest < ActiveSupport::TestCase
  should have_db_column :id
  should have_db_column :token
  should have_db_column :title
  should have_db_column :original_csv_data
  should have_db_column :location_column_name
  should have_db_column :location_column_type
  should have_db_column :data_column_name
  should have_db_column :data_column_type
  should have_db_column :geoiq_dataset_xid
  should have_db_column :geoiq_map_xid
  should have_db_column :created_at
  should have_db_column :updated_at
  should have_db_index :token

  should validate_presence_of :title
  should validate_presence_of :token
  should validate_presence_of :original_csv_data
  should validate_presence_of :location_column_name
  should validate_presence_of :location_column_type
  should validate_presence_of :data_column_name
  should validate_presence_of :data_column_type

  should "hard code #map_provider" do
    assert_equal "OpenStreetMap (Road)", Map.new.map_provider
  end
end

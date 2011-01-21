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
  should validate_presence_of :original_csv_data
  should validate_presence_of :location_column_name
  should validate_presence_of :location_column_type
  should validate_presence_of :data_column_name
  should validate_presence_of :data_column_type

  should "hard code #provider" do
    assert_equal "OpenStreetMap (Road)", Map.new.provider
  end

  should "assign a 6 character token whle creating a new record" do
    map = Factory.build(:map)
    assert_nil map.token
    map.save
    assert map.token
    assert_equal 6, map.token.length
  end

  should "not reassign the token after update" do
    map = Factory.create(:map)
    token = map.token
    assert token
    map.update_attribute(:title, "New Title")
    assert_equal token, map.reload.token
  end

  context "#to_param" do
    def self.should_return(expected, token, title)
      should "render as #{expected.inspect} for token => #{token} and title => #{title.inspect}" do
        map = Map.new(:title => title, :token => token)
        assert_equal expected, map.to_param
      end
    end

    should_return "00beef-name",       "00beef", "name"
    should_return "00beef-a-b-c",      "00beef", "  a b  c \t "
    should_return "00beef-a-s-b-c",    "00beef", "a's 'b' c"
    should_return "00beef-abc-def",    "00beef", "Abc Def"
    should_return "00beef",            "00beef", nil
  end
end

class AddGeoiqIdToMaps < ActiveRecord::Migration
  def self.up
    add_column :maps, :geoiq_id, :integer, :default => nil
  end

  def self.down
    remove_column :maps, :geoiq_id
  end
end

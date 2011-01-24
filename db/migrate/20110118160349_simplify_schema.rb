require 'csv'
class Dataset < ActiveRecord::Base
  belongs_to :map
  serialize :data_columns, Hash
  serialize :location_columns, ActiveSupport::OrderedHash
end
class Map < ActiveRecord::Base; end

class SimplifySchema < ActiveRecord::Migration
  def self.up
    change_table(:maps) do |t|
      t.rename :maker_id, :geoiq_map_xid     # poorly named originally
      t.rename :linkable_id, :token          # switching to more conventional naming
      t.remove :description                  # wasn't used
      t.remove :dataset_id                   # unnused reference in the wrong direction
      t.remove :geoiq_id                     # wasn't used
      t.remove :map_provider                 # was always hard coded to "OpenStreetMap (Road)"
      t.change :geoiq_map_xid, :string       # external identifiers should be stored as strings
      t.string :geoiq_dataset_xid            # from dataset; external identifiers should be stored as strings
      t.text   :original_csv_data            # from dataset; switching to longer blob of characters
      t.string :location_column_name         # from dataset; the old serialized hash was unnecessary
      t.string :location_column_type         # from dataset; the old serialized hash was unnecessary
      t.string :data_column_name             # from dataset; the old serialized hash was unnecessary
      t.string :data_column_type             # from dataset; the old serialized hash was unnecessary
      t.index  :token                        # important part of Map#to_param
    end

    consolidate_datasets_into_maps

    drop_table :datasets
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

  def self.consolidate_datasets_into_maps
    Map.reset_column_information
    Dataset.find_each do |ds|
      map = ds.map
      map.geoiq_dataset_xid    = ds.finder_id
      map.location_column_name = ds.location_columns.keys.first
      map.location_column_type = ds.location_columns.values.first
      map.data_column_name     = ds.data_columns.keys.first
      map.data_column_type     = ds.data_columns.values.first
      map.original_csv_data    = convert_data_to_csv(ds.data, ds.separator)
      map.save!
    end
  end

  def self.convert_data_to_csv(data, delimiter)
    return data if delimiter == "," || delimiter.blank?
    options = { :col_sep => delimiter, :headers => true, :skip_blanks => true }
    CSV.new(data, options).read.to_csv
  end
end

class AddDataAndLocationColumnsToDatasets < ActiveRecord::Migration
  def self.up
    add_column :datasets, :data_columns, :string
    add_column :datasets, :location_columns, :string
  end

  def self.down
    remove_column :datasets, :data_columns
    remove_column :datasets, :location_columns
  end
end

class AddColumnSeparatorToDatasets < ActiveRecord::Migration
  def self.up
    add_column :datasets, :separator, :string, :default => ","
  end

  def self.down
    remove_column :datasets, :separator
  end
end

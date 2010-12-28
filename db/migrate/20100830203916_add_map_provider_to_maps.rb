class AddMapProviderToMaps < ActiveRecord::Migration
  def self.up
    add_column :maps, :map_provider, :string
  end

  def self.down
    remove_column :maps, :map_provider
  end
end

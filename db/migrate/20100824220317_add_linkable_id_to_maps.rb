class AddLinkableIdToMaps < ActiveRecord::Migration
  def self.up
    add_column :maps, :linkable_id, :string
  end

  def self.down
    remove_column :maps, :linkable_id
  end
end

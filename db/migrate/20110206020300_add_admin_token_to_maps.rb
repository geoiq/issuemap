class AddAdminTokenToMaps < ActiveRecord::Migration
  def self.up
    add_column :maps, :admin_token, :string
  end

  def self.down
    remove_column :maps, :admin_token
  end
end

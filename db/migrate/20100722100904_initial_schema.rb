class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table "datasets", :force => true do |t|
      t.integer  "finder_id"
      t.text     "data"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "map_id"
      t.string   "upload_file_name"
      t.string   "upload_content_type"
      t.integer  "upload_file_size"
      t.datetime "upload_updated_at"
    end

    add_index "datasets", ["map_id"], :name => "index_datasets_on_map_id"

    create_table "maps", :force => true do |t|
      t.integer  "maker_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "title"
      t.text     "description"
      t.integer  "dataset_id"
    end
  end

  def self.down
    drop_table :datasets
    drop_table :maps
  end
end

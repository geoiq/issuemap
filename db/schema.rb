# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100830203916) do

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
    t.string   "data_columns"
    t.string   "location_columns"
    t.string   "separator",           :default => ","
  end

  add_index "datasets", ["map_id"], :name => "index_datasets_on_map_id"

  create_table "maps", :force => true do |t|
    t.integer  "maker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.text     "description"
    t.integer  "dataset_id"
    t.integer  "geoiq_id"
    t.string   "linkable_id"
    t.string   "map_provider"
  end

end

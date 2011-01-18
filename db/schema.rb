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

ActiveRecord::Schema.define(:version => 20110118160349) do

  create_table "maps", :force => true do |t|
    t.string   "geoiq_map_xid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "token"
    t.string   "geoiq_dataset_xid"
    t.text     "original_csv_data"
    t.string   "location_column_name"
    t.string   "location_column_type"
    t.string   "data_column_name"
    t.string   "data_column_type"
  end

  add_index "maps", ["token"], :name => "index_maps_on_token"

end

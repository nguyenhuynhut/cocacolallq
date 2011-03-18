# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110312060857) do

  create_table "bid_activities", :force => true do |t|
    t.integer  "liquor_license_auction_id"
    t.integer  "user_id"
    t.date     "expiration_date"
    t.boolean  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "criteria_activities", :force => true do |t|
    t.integer  "liquor_license_id"
    t.integer  "user_id"
    t.date     "expiration_date"
    t.boolean  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "criterias", :force => true do |t|
    t.integer  "state_id"
    t.integer  "city_id"
    t.integer  "user_id"
    t.integer  "license_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "geoinfo_cities", :force => true do |t|
    t.string   "name"
    t.integer  "state_id"
    t.integer  "gnis_id"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "population_2000"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "geoinfo_states", :force => true do |t|
    t.string   "name"
    t.string   "abbr"
    t.string   "country"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "license_types", :force => true do |t|
    t.string   "license_code"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "liquor_license_auctions", :force => true do |t|
    t.float    "price"
    t.integer  "liquor_license_id"
    t.boolean "status"
    t.integer  "user_id"
    t.integer  "bidder_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "liquor_licenses", :force => true do |t|
    t.string   "title"
    t.string   "location"
    t.integer  "state_id"
    t.integer  "city_id"
    t.string   "url"
    t.float    "price"
    t.date     "expiration_date"
    t.string   "from_host"
    t.string   "purpose"
    t.string   "email"
    t.integer  "user_id"
    t.integer  "buyer_id"
    t.integer  "license_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_details", :force => true do |t|
    t.string   "real_name"
    t.string   "street_address"
    t.integer  "city_id"
    t.integer  "state_id"
    t.integer  "post_code"
    t.string   "avatar"
    t.string   "gender"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "username"
    t.string   "password"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

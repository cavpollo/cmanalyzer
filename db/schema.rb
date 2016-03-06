# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150904000004) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "last_data_loads", force: :cascade do |t|
    t.string   "process_name",   null: false
    t.string   "last_keen_date", null: false
    t.string   "last_keen_id",   null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "unique_devices", force: :cascade do |t|
    t.string   "device_id",                    null: false
    t.string   "device_model",                 null: false
    t.string   "device_device",                null: false
    t.float    "device_density",               null: false
    t.float    "device_height",                null: false
    t.float    "device_width",                 null: false
    t.float    "device_h_diff",                null: false
    t.integer  "play_count",                   null: false
    t.date     "first_play_date",              null: false
    t.date     "last_play_date",               null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "device_brand",    default: "", null: false
    t.string   "device_name",     default: "", null: false
  end

  create_table "unique_users", force: :cascade do |t|
    t.integer  "unique_device_id", null: false
    t.string   "user_gplay_id",    null: false
    t.string   "user_gender",      null: false
    t.string   "user_language",    null: false
    t.date     "first_play_date",  null: false
    t.date     "last_play_date",   null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "unique_versions", force: :cascade do |t|
    t.integer  "unique_device_id", null: false
    t.string   "game_version",     null: false
    t.integer  "play_count",       null: false
    t.date     "first_play_date",  null: false
    t.date     "last_play_date",   null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

end

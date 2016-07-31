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

ActiveRecord::Schema.define(version: 20160605000000) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "daily_events", force: :cascade do |t|
    t.date     "event_date",                     null: false
    t.integer  "install_count",      default: 0, null: false
    t.integer  "upgrade_count",      default: 0, null: false
    t.integer  "uninstall_count",    default: 0, null: false
    t.integer  "active_users_count", default: 0, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "last_data_loads", force: :cascade do |t|
    t.string   "process_name",   null: false
    t.datetime "last_keen_date", null: false
    t.string   "last_keen_id",   null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "screen_user_days", force: :cascade do |t|
    t.integer  "unique_device_id", default: 0, null: false
    t.integer  "unique_user_id",   default: 0, null: false
    t.string   "screen_name",                  null: false
    t.integer  "day",              default: 0, null: false
    t.integer  "access_count",     default: 0, null: false
    t.string   "version",                      null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "unique_devices", force: :cascade do |t|
    t.string   "device_id",                      null: false
    t.string   "device_model",                   null: false
    t.string   "device_device",                  null: false
    t.float    "device_density",                 null: false
    t.float    "device_height",                  null: false
    t.float    "device_width",                   null: false
    t.float    "device_h_diff",                  null: false
    t.integer  "play_count",                     null: false
    t.date     "first_play_date",                null: false
    t.date     "last_play_date",                 null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "device_brand",    default: "",   null: false
    t.string   "device_name",     default: "",   null: false
    t.boolean  "valid_device",    default: true, null: false
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

  create_table "user_screen_days", force: :cascade do |t|
    t.string   "screen_name",              null: false
    t.integer  "data_type",    default: 0, null: false
    t.integer  "day",          default: 0, null: false
    t.integer  "access_count", default: 0, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "user_screen_events", force: :cascade do |t|
    t.integer  "unique_device_id",             null: false
    t.string   "screen_name",                  null: false
    t.date     "first_date",                   null: false
    t.date     "last_date",                    null: false
    t.integer  "access_count",     default: 0, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

end

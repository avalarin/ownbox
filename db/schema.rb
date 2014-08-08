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

ActiveRecord::Schema.define(version: 20140711025455) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "items", force: true do |t|
    t.string  "name"
    t.string  "path"
    t.string  "full_path"
    t.integer "user_id"
    t.string  "type"
    t.string  "class_name"
  end

  add_index "items", ["path", "user_id"], name: "index_items_on_path_and_user_id", using: :btree

  create_table "previews", force: true do |t|
    t.string  "path"
    t.integer "size"
    t.binary  "data"
  end

  create_table "share_permissions", force: true do |t|
    t.integer "user_id"
    t.integer "share_id"
    t.string  "permission"
  end

  create_table "shares", force: true do |t|
    t.string  "name"
    t.integer "item_id"
  end

end

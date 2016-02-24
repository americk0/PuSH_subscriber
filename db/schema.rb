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

ActiveRecord::Schema.define(version: 20160309033502) do

  create_table "entries", force: :cascade do |t|
    t.string   "title"
    t.string   "author"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "body"
    t.integer  "entry_id"
    t.integer  "feed_id"
  end

  add_index "entries", ["entry_id"], name: "index_entries_on_entry_id"
  add_index "entries", ["feed_id"], name: "index_entries_on_feed_id"

  create_table "feeds", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "feed_url"
  end

  add_index "feeds", ["feed_url"], name: "index_feeds_on_feed_url"

end

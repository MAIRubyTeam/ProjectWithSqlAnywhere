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

ActiveRecord::Schema.define(version: 20150429103255) do

  create_table "groups", force: true do |t|
    t.string "name", null: false
  end

  add_index "groups", ["name"], name: "index_groups_on_name", unique: true

  create_table "groups_url_types", force: true do |t|
    t.integer "url_type_id"
    t.integer "group_id"
  end

  create_table "groups_users", force: true do |t|
    t.integer "user_id"
    t.integer "group_id"
  end

  create_table "rs_lastcommit", primary_key: "origin", force: true do |t|
    t.binary   "origin_qid",    limit: 36
    t.binary   "secondary_qid", limit: 36
    t.datetime "origin_time"
    t.datetime "commit_time"
  end

  create_table "rs_threads", force: true do |t|
    t.integer "seq"
  end

  create_table "url_types", force: true do |t|
    t.string "name"
  end

  add_index "url_types", ["name"], name: "index_url_types_on_name", unique: true

  create_table "urls", force: true do |t|
    t.string  "url_pattern"
    t.string  "name"
    t.integer "url_type_id"
    t.integer "sorder"
  end

  create_table "users", force: true do |t|
    t.string  "name",   limit: 30, null: false
    t.integer "passwd", limit: 8,  null: false
  end

  add_index "users", ["name"], name: "index_users_on_name", unique: true

end

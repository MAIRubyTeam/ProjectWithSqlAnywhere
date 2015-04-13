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

ActiveRecord::Schema.define(version: 20150401074550) do

  create_table "renew_menu_tree", id: false, force: true do |t|
    t.integer "id"
    t.integer "parent"
  end

  add_index "renew_menu_tree", ["id", "parent"], name: "index_renew_menu_tree_on_id_and_parent", unique: true

  create_table "renew_page_content", force: true do |t|
    t.integer "page_part_id"
    t.integer "renew_url_id"
    t.text    "html"
    t.integer "width"
    t.integer "height"
  end

  create_table "renew_url", force: true do |t|
    t.string  "url_pattern"
    t.string  "name"
    t.integer "url_type_id"
    t.integer "sorder"
  end

  create_table "renew_url_type", force: true do |t|
    t.string "name"
  end

  add_index "renew_url_type", ["name"], name: "index_renew_url_type_on_name", unique: true

  create_table "renew_user_group", force: true do |t|
    t.string "name"
  end

  add_index "renew_user_group", ["name"], name: "index_renew_user_group_on_name", unique: true

  create_table "renew_users", force: true do |t|
    t.string "name"
  end

  add_index "renew_users", ["name"], name: "index_renew_users_on_name", unique: true

  create_table "renew_users_groups", force: true do |t|
    t.integer "renew_user_id"
    t.integer "renew_user_group_id"
  end

  add_index "renew_users_groups", ["renew_user_id", "renew_user_group_id"], name: "index_users_groups_on_user_id_and_user_group_id", unique: true

  create_table "renew_users_urls", force: true do |t|
    t.integer "renew_user_group_id"
    t.integer "renew_user_url_id"
  end

  add_index "renew_users_urls", ["renew_user_group_id", "renew_user_url_id"], name: "index_users_urls_on_user_group_id_and_url_id", unique: true

  create_table "rs_lastcommit", primary_key: "origin", force: true do |t|
    t.binary   "origin_qid",    limit: 36
    t.binary   "secondary_qid", limit: 36
    t.datetime "origin_time"
    t.datetime "commit_time"
  end

  create_table "rs_threads", force: true do |t|
    t.integer "seq"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

end

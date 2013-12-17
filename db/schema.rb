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

ActiveRecord::Schema.define(version: 20131216224208) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "jobs", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "schedules", force: true do |t|
    t.integer  "job_id"
    t.integer  "user_id"
    t.decimal  "hours"
    t.date     "schedule_date"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.datetime "from_time"
    t.datetime "to_time"
  end

  add_index "schedules", ["user_id", "schedule_date"], name: "index_schedules_on_user_id_and_schedule_date", using: :btree

  create_table "time_off_request_statuses", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_off_requests", force: true do |t|
    t.integer  "user_id"
    t.integer  "manager_id"
    t.date     "day_off_requested"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_id"
  end

  create_table "user_types", force: true do |t|
    t.string   "name"
    t.boolean  "admin"
    t.boolean  "manager"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "full_name"
    t.integer  "user_type_id"
    t.integer  "manager_id"
    t.string   "phone_number"
    t.string   "address"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["manager_id"], name: "index_users_on_manager_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end

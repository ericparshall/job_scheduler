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

ActiveRecord::Schema.define(version: 20150131223904) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customers", force: true do |t|
    t.string   "name"
    t.boolean  "archived",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "customers", ["archived"], name: "index_customers_on_archived", using: :btree

  create_table "future_schedules", force: true do |t|
    t.integer  "job_id"
    t.datetime "from_time"
    t.datetime "to_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "through_date"
  end

  create_table "jobs", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "archived",                     default: false
    t.integer  "customer_id"
    t.integer  "point_of_contact_id"
    t.integer  "internal_point_of_contact_id"
  end

  add_index "jobs", ["archived"], name: "index_jobs_on_archived", using: :btree

  create_table "jobs_skills", id: false, force: true do |t|
    t.integer "job_id"
    t.integer "skill_id"
  end

  create_table "point_of_contacts", force: true do |t|
    t.integer  "customer_id"
    t.string   "name"
    t.string   "address"
    t.string   "phone_number"
    t.string   "email_address"
    t.boolean  "archived",      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schedules", force: true do |t|
    t.integer  "job_id"
    t.integer  "user_id"
    t.decimal  "hours"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "from_time"
    t.datetime "to_time"
  end

  add_index "schedules", ["user_id", "from_time", "to_time"], name: "index_schedules_on_user_id_and_from_time_and_to_time", using: :btree
  add_index "schedules", ["user_id"], name: "index_schedules_on_user_id", using: :btree

  create_table "skills", force: true do |t|
    t.string   "name"
    t.boolean  "archived",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_off_request_statuses", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_off_requests", force: true do |t|
    t.integer  "user_id"
    t.integer  "manager_id"
    t.date     "from_date"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_id"
    t.date     "to_date"
  end

  create_table "user_types", force: true do |t|
    t.string   "name"
    t.boolean  "admin"
    t.boolean  "manager"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name"
    t.integer  "user_type_id"
    t.integer  "manager_id"
    t.string   "phone_number"
    t.string   "address"
    t.boolean  "archived",               default: false
    t.integer  "rating",                 default: 0
  end

  add_index "users", ["archived"], name: "index_users_on_archived", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["manager_id"], name: "index_users_on_manager_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_skills", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "skill_id"
  end

  add_index "users_skills", ["user_id", "skill_id"], name: "index_users_skills_on_user_id_and_skill_id", using: :btree

end

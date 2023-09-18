# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_09_10_154256) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "email_verification_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_email_verification_tokens_on_user_id"
  end

  create_table "goals", force: :cascade do |t|
    t.decimal "target_value"
    t.integer "month"
    t.integer "year"
    t.bigint "spend_account_id"
    t.bigint "spend_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["month", "year", "spend_account_id", "spend_category_id"], name: "index_goals", unique: true
    t.index ["spend_account_id"], name: "index_goals_on_spend_account_id"
    t.index ["spend_category_id"], name: "index_goals_on_spend_category_id"
  end

  create_table "password_reset_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_password_reset_tokens_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "spend_accounts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_spend_accounts_on_user_id"
  end

  create_table "spend_categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "identifier", null: false
    t.boolean "is_standard_expense", default: false, null: false
    t.boolean "is_needed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spends", force: :cascade do |t|
    t.bigint "spend_account_id", null: false
    t.bigint "spend_category_id"
    t.string "description", null: false
    t.decimal "amount", null: false
    t.date "date_of_spend", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notes"
    t.index ["spend_account_id"], name: "index_spends_on_spend_account_id"
    t.index ["spend_category_id"], name: "index_spends_on_spend_category_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "verified", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "email_verification_tokens", "users"
  add_foreign_key "goals", "spend_accounts"
  add_foreign_key "goals", "spend_categories"
  add_foreign_key "password_reset_tokens", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "spend_accounts", "users"
  add_foreign_key "spends", "spend_accounts"
  add_foreign_key "spends", "spend_categories"
end

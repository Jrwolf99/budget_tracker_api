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

ActiveRecord::Schema[7.0].define(version: 2023_07_02_025052) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "category_name", limit: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "goals", force: :cascade do |t|
    t.integer "month", null: false
    t.integer "year", null: false
    t.bigint "category_id", null: false
    t.decimal "goal_amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "month", "year"], name: "index_goals_on_category_id_and_month_and_year", unique: true
    t.index ["category_id"], name: "index_goals_on_category_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "description"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "transaction_date"
    t.string "notes", limit: 50
    t.integer "year"
    t.integer "month"
    t.bigint "category_id"
    t.index ["category_id"], name: "index_transactions_on_category_id"
    t.index ["description", "amount", "transaction_date"], name: "index_transactions_on_desc_amount_date", unique: true
  end

  add_foreign_key "goals", "categories"
  add_foreign_key "transactions", "categories"
end

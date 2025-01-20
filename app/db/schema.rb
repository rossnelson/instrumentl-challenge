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

ActiveRecord::Schema[7.2].define(version: 2025_01_20_004319) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "inspection_kinds", force: :cascade do |t|
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "inspections", force: :cascade do |t|
    t.datetime "occurred_at", null: false
    t.integer "score"
    t.bigint "inspection_kind_id", null: false
    t.bigint "location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inspection_kind_id"], name: "index_inspections_on_inspection_kind_id"
    t.index ["location_id"], name: "index_inspections_on_location_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.bigint "owner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "search_vector", type: :tsvector, as: "to_tsvector('english'::regconfig, (((((((((COALESCE(name, ''::character varying))::text || ' '::text) || (COALESCE(street, ''::character varying))::text) || ' '::text) || (COALESCE(city, ''::character varying))::text) || ' '::text) || (COALESCE(state, ''::character varying))::text) || ' '::text) || (COALESCE(postal_code, ''::character varying))::text))", stored: true
    t.index ["owner_id"], name: "index_locations_on_owner_id"
    t.index ["search_vector"], name: "index_locations_on_search_vector", using: :gin
  end

  create_table "owners", force: :cascade do |t|
    t.string "name", null: false
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "risk_categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "violation_kinds", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "violations", force: :cascade do |t|
    t.datetime "occurred_at", null: false
    t.string "description", null: false
    t.bigint "violation_kind_id", null: false
    t.bigint "inspection_id", null: false
    t.bigint "location_id", null: false
    t.bigint "risk_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inspection_id"], name: "index_violations_on_inspection_id"
    t.index ["location_id"], name: "index_violations_on_location_id"
    t.index ["risk_category_id"], name: "index_violations_on_risk_category_id"
    t.index ["violation_kind_id"], name: "index_violations_on_violation_kind_id"
  end

  add_foreign_key "inspections", "inspection_kinds"
  add_foreign_key "inspections", "locations"
  add_foreign_key "locations", "owners"
  add_foreign_key "violations", "inspections"
  add_foreign_key "violations", "locations"
  add_foreign_key "violations", "risk_categories"
  add_foreign_key "violations", "violation_kinds"
end

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

ActiveRecord::Schema[8.1].define(version: 2026_07_03_100002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "events", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "capacity", default: 100, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.text "description"
    t.datetime "ends_at"
    t.integer "free_dev_seats", default: 0, null: false
    t.string "location"
    t.string "name", null: false
    t.integer "price_cents", default: 0, null: false
    t.string "slug", null: false
    t.datetime "starts_at"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_events_on_slug", unique: true
  end

  create_table "registrations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.bigint "event_id", null: false
    t.string "name", null: false
    t.string "phone"
    t.string "registered_by"
    t.string "seat_type", default: "paid", null: false
    t.string "source", default: "web", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "email"], name: "index_registrations_on_event_id_and_email", unique: true
    t.index ["event_id"], name: "index_registrations_on_event_id"
  end

  add_foreign_key "registrations", "events"
end

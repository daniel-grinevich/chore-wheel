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

ActiveRecord::Schema[8.0].define(version: 2026_07_12_232729) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.bigint "chore_id", null: false
    t.bigint "person_id", null: false
    t.date "week_start", null: false
    t.date "scheduled_on", null: false
    t.integer "status", default: 0, null: false
    t.integer "estimate_minutes", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chore_id"], name: "index_assignments_on_chore_id"
    t.index ["person_id"], name: "index_assignments_on_person_id"
    t.index ["week_start", "chore_id"], name: "index_assignments_on_week_start_and_chore_id", unique: true
    t.index ["week_start", "person_id"], name: "index_assignments_on_week_start_and_person_id"
  end

  create_table "chores", force: :cascade do |t|
    t.string "name", null: false
    t.integer "base_estimate_minutes", default: 15, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "people", force: :cascade do |t|
    t.string "name", null: false
    t.string "color", default: "#4f46e5", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "work_sessions", force: :cascade do |t|
    t.bigint "assignment_id", null: false
    t.datetime "started_at", null: false
    t.datetime "ended_at"
    t.integer "duration_seconds"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_work_sessions_on_assignment_id"
  end

  add_foreign_key "assignments", "chores"
  add_foreign_key "assignments", "people"
  add_foreign_key "work_sessions", "assignments"
end

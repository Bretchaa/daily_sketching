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

ActiveRecord::Schema[7.2].define(version: 2026_01_02_162753) do
  create_table "challenges", force: :cascade do |t|
    t.date "date"
    t.string "theme"
    t.string "focus"
    t.string "tip"
    t.string "example_image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "poses", force: :cascade do |t|
    t.integer "challenge_id", null: false
    t.string "image_url"
    t.integer "duration_seconds"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_id"], name: "index_poses_on_challenge_id"
  end

  add_foreign_key "poses", "challenges"
end

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

ActiveRecord::Schema[8.1].define(version: 2026_09_19_172317) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "challenges", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.string "example_image_url"
    t.string "focus"
    t.string "theme"
    t.string "tip"
    t.datetime "updated_at", null: false
  end

  create_table "cheers", force: :cascade do |t|
    t.integer "count", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "submission_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["submission_id"], name: "index_cheers_on_submission_id"
    t.index ["user_id", "submission_id"], name: "index_cheers_on_user_id_and_submission_id", unique: true
    t.index ["user_id"], name: "index_cheers_on_user_id"
  end

  create_table "pose_images", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "path", null: false
    t.string "tags", default: ""
    t.string "theme", null: false
    t.datetime "updated_at", null: false
    t.index ["path"], name: "index_pose_images_on_path", unique: true
    t.index ["theme"], name: "index_pose_images_on_theme"
  end

  create_table "poses", force: :cascade do |t|
    t.integer "challenge_id", null: false
    t.datetime "created_at", null: false
    t.integer "duration_seconds"
    t.string "image_url"
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["challenge_id"], name: "index_poses_on_challenge_id"
  end

  create_table "shield_uses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "date"], name: "index_shield_uses_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_shield_uses_on_user_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.integer "challenge_id", null: false
    t.datetime "created_at", null: false
    t.string "note"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["challenge_id"], name: "index_submissions_on_challenge_id"
    t.index ["user_id", "challenge_id"], name: "index_submissions_on_user_id_and_challenge_id", unique: true
    t.index ["user_id"], name: "index_submissions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "email"
    t.boolean "email_notifications", default: true, null: false
    t.datetime "first_followup_sent_at"
    t.string "name"
    t.string "password_digest"
    t.string "provider"
    t.datetime "reengagement_sent_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.boolean "restart_shield_granted", default: false, null: false
    t.integer "shield_milestone_day", default: 0, null: false
    t.integer "shields_count", default: 0, null: false
    t.datetime "streak_break_sent_at"
    t.string "uid"
    t.string "unsubscribe_token"
    t.datetime "updated_at", null: false
    t.string "upload_token"
    t.string "username"
    t.index ["unsubscribe_token"], name: "index_users_on_unsubscribe_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cheers", "submissions"
  add_foreign_key "cheers", "users"
  add_foreign_key "poses", "challenges"
  add_foreign_key "shield_uses", "users"
  add_foreign_key "submissions", "challenges"
  add_foreign_key "submissions", "users"
end

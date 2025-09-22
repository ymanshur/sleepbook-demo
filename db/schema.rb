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

ActiveRecord::Schema[8.0].define(version: 2025_09_22_201437) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "follows", force: :cascade do |t|
    t.bigint "follower_id", null: false
    t.bigint "followed_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id"], name: "index_follows_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_follows_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "user_sleeps", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time"
    t.integer "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "start_time", "duration"], name: "index_part_user_sleeps_on_user_id_and_start_time_and_duration", where: "(end_time IS NOT NULL)", include: ["end_time"]
    t.index ["user_id"], name: "index_user_sleeps_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "follows", "users", column: "followed_id"
  add_foreign_key "follows", "users", column: "follower_id"
  add_foreign_key "user_sleeps", "users"

  create_view "recent_followee_sleeps", materialized: true, sql_definition: <<-SQL
    SELECT (md5(concat((f.follower_id)::text, '-', (us.id)::text)))::uuid AS id,
        f.follower_id,
        us.id AS sleep_id,
        us.user_id,
        us.duration
    FROM ((follows f
        JOIN users u ON ((f.followed_id = u.id)))
        JOIN user_sleeps us ON ((us.user_id = u.id)))
    WHERE ((us.end_time IS NOT NULL) AND (us.start_time >= (now() - 'P14D'::interval)))
    ORDER BY us.duration DESC;
  SQL
  add_index "recent_followee_sleeps", ["follower_id", "duration"], name: "index_recent_followee_sleeps_on_follower_id_and_duration", order: { duration: :desc }
  add_index "recent_followee_sleeps", ["follower_id", "sleep_id"], name: "index_recent_followee_sleeps_on_follower_id_and_sleep_id", unique: true

end

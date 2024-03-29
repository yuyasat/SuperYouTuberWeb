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

ActiveRecord::Schema.define(version: 20180814000000) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "advertisements", force: :cascade do |t|
    t.string "path", null: false
    t.integer "device", default: 3, null: false
    t.integer "location", null: false
    t.jsonb "target"
    t.datetime "start_at", null: false
    t.datetime "end_at"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "match_type", default: 1, null: false
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "full_name", null: false
    t.integer "parent_id", default: 0, null: false
    t.integer "display_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "featured_movies", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_featured_movies_on_movie_id"
  end

  create_table "locations", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.geography "lonlat", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_locations_on_movie_id"
  end

  create_table "memos", force: :cascade do |t|
    t.string "target_type"
    t.bigint "target_id"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["target_type", "target_id"], name: "index_memos_on_target_type_and_target_id"
  end

  create_table "movie_categories", id: :serial, force: :cascade do |t|
    t.integer "movie_id", null: false
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_movie_categories_on_category_id"
    t.index ["movie_id"], name: "index_movie_categories_on_movie_id"
  end

  create_table "movie_registration_definitions", force: :cascade do |t|
    t.bigint "video_artist_id", null: false
    t.bigint "category_id", null: false
    t.string "definition", null: false
    t.integer "match_type", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_movie_registration_definitions_on_category_id"
    t.index ["video_artist_id"], name: "index_movie_registration_definitions_on_video_artist_id"
  end

  create_table "movie_tags", id: :serial, force: :cascade do |t|
    t.integer "movie_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_movie_tags_on_movie_id"
    t.index ["tag_id"], name: "index_movie_tags_on_tag_id"
  end

  create_table "movies", id: :serial, force: :cascade do |t|
    t.string "url", null: false
    t.string "key", null: false
    t.integer "status", default: 1, null: false
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "published_at"
    t.string "channel"
    t.integer "registered_type", default: 1, null: false
  end

  create_table "sns_accounts", id: :serial, force: :cascade do |t|
    t.string "type", null: false
    t.integer "video_artist_id", null: false
    t.string "account", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["video_artist_id"], name: "index_sns_accounts_on_video_artist_id"
  end

  create_table "special_categories", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_special_categories_on_category_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "video_artists", id: :serial, force: :cascade do |t|
    t.string "channel", null: false
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "custom_url"
    t.text "editor_description"
    t.text "description"
    t.string "default_thumbnail_url"
    t.string "medium_thumbnail_url"
    t.string "high_thumbnail_url"
    t.string "kana"
    t.string "en"
    t.datetime "latest_published_at"
    t.integer "auto_movie_registration_type", default: 0, null: false
  end

end

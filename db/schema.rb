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

ActiveRecord::Schema.define(version: 2021_04_13_163715) do

  create_table "activities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "action"
    t.datetime "action_at"
    t.string "kind"
    t.integer "kind_id"
    t.integer "user_id"
  end

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "analytics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "applies", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "nickname"
    t.text "description"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "resume_file_name"
    t.string "resume_content_type"
    t.integer "resume_file_size"
    t.datetime "resume_updated_at"
    t.string "sample_writing_file_name"
    t.string "sample_writing_content_type"
    t.integer "sample_writing_file_size"
    t.datetime "sample_writing_updated_at"
    t.string "grade"
    t.integer "user_id"
    t.text "editor_revision"
    t.text "editor_feedback"
    t.text "editor_pitches"
    t.string "kind"
    t.string "rejected_writer_at"
    t.string "rejected_editor_at"
  end

  create_table "badges", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "level"
    t.string "color"
    t.integer "user_id"
    t.boolean "activated"
    t.string "kind"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "slug"
    t.string "image_file_name"
    t.string "image_content_type"
    t.bigint "image_file_size"
    t.datetime "image_updated_at"
    t.string "description"
    t.boolean "archive"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string "data_file_name", null: false
    t.string "data_content_type"
    t.integer "data_file_size"
    t.string "data_fingerprint"
    t.string "type", limit: 30
    t.integer "width"
    t.integer "height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type"], name: "index_ckeditor_assets_on_type"
  end

  create_table "comments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "text"
    t.integer "user_id"
    t.integer "post_id"
    t.integer "comment_id"
    t.text "response_to"
  end

  create_table "constants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "value"
    t.string "slug"
  end

  create_table "feedback_givens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "feedback_id"
    t.integer "review_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "editor_descr"
    t.text "review_descr"
    t.boolean "archive"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "impressions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "Impression_count"
  end

  create_table "mailers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "newsletters", force: :cascade do |t|
    t.text "message"
    t.string "kind"
    t.string "background_color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ready"
    t.datetime "sent_at"
    t.integer "user_id"
    t.string "hero_image_file_name"
    t.string "hero_image_content_type"
    t.bigint "hero_image_file_size"
    t.datetime "hero_image_updated_at"
  end

  create_table "outreaches", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "partner_email"
    t.string "partner_name"
    t.integer "user_id"
    t.text "email_draft"
    t.boolean "sent"
  end

  create_table "phrasing_phrase_versions", force: :cascade do |t|
    t.integer "phrasing_phrase_id"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phrasing_phrase_id"], name: "index_phrasing_phrase_versions_on_phrasing_phrase_id"
  end

  create_table "phrasing_phrases", force: :cascade do |t|
    t.string "locale"
    t.string "key"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pitches", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "thumbnail_file_name"
    t.string "thumbnail_content_type"
    t.integer "thumbnail_file_size", limit: 8
    t.datetime "thumbnail_updated_at"
    t.integer "category_id"
    t.integer "user_id"
    t.integer "claimed_id"
    t.text "requirements"
    t.boolean "assign_if_not_claimed"
    t.text "status"
    t.text "notes"
    t.integer "editor_id"
    t.boolean "rejected_title"
    t.boolean "rejected_topic"
    t.boolean "rejected_thumbnail"
    t.integer "deadline"
    t.boolean "archive"
    t.datetime "claimed_at"
    t.index ["slug"], name: "index_pitches_on_slug", unique: true
    t.index ["updated_at"], name: "index_pitches_on_updated_at"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "image"
    t.text "meta_description"
    t.text "keywords"
    t.string "category"
    t.integer "user_id"
    t.integer "admin_id"
    t.boolean "approved"
    t.boolean "waiting_for_approval"
    t.boolean "after_approved"
    t.string "category_id"
    t.string "thumbnail_file_name"
    t.string "thumbnail_content_type"
    t.integer "thumbnail_file_size", limit: 8
    t.datetime "thumbnail_updated_at"
    t.integer "post_impressions", default: 0
    t.integer "ranking"
    t.string "collaboration"
    t.integer "pitch_id"
    t.datetime "publish_at"
    t.integer "feedback_list", default: 0
    t.boolean "sharing"
    t.boolean "editor_can_make_changes"
    t.datetime "promoting_until"
    t.integer "partner_id"
    t.boolean "featured"
    t.datetime "deadline_at"
    t.integer "newsletter_id"
    t.index ["post_impressions"], name: "index_posts_on_post_impressions"
    t.index ["publish_at"], name: "index_posts_on_publish_at"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_projects_on_slug", unique: true
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "In Progress"
    t.boolean "active"
    t.integer "editor_id"
    t.text "notes"
    t.integer "feedback", default: 0
    t.datetime "editor_claimed_review_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "image"
    t.text "description"
    t.text "first_name"
    t.text "last_name"
    t.text "website"
    t.text "insta"
    t.text "twitter"
    t.text "facebook"
    t.text "pintrest"
    t.text "youtube"
    t.text "snap"
    t.boolean "admin"
    t.string "profile_file_name"
    t.string "profile_content_type"
    t.integer "profile_file_size", limit: 8
    t.datetime "profile_updated_at"
    t.boolean "editor"
    t.string "full_name"
    t.string "slug"
    t.integer "posts_count"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "category"
    t.string "nickname"
    t.integer "monthly_views"
    t.boolean "submitted_profile"
    t.boolean "approved_profile"
    t.boolean "bi_monthly_assignment"
    t.boolean "do_not_send_emails"
    t.datetime "last_saw_pitches"
    t.datetime "last_saw_peer_feedback"
    t.datetime "last_saw_writer_applications"
    t.datetime "last_saw_editor_dashboard"
    t.datetime "last_saw_community"
    t.integer "points", default: 0
    t.boolean "partner"
    t.integer "onboarding_claimed_pitch_id"
    t.boolean "read_pitches"
    t.boolean "read_articles"
    t.boolean "read_images"
    t.string "last_saw_new_writer_dashboard"
    t.string "last_saw_dashboard"
    t.string "last_saw_writer_dashboard"
    t.string "became_an_editor"
    t.boolean "completed_editor_onboarding"
    t.datetime "missed_editor_deadline"
    t.boolean "notify_of_new_review"
    t.integer "extensions", default: 1
    t.boolean "has_newsletter_permissions"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["full_name"], name: "index_users_on_full_name"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

end

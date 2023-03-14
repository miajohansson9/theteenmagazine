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

ActiveRecord::Schema[7.0].define(version: 2023_03_14_184433) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "action"
    t.datetime "action_at", precision: nil
    t.string "kind"
    t.integer "kind_id"
    t.integer "user_id"
  end

  create_table "admins", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "analytics", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "applies", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "nickname"
    t.text "description"
    t.string "category"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "resume_file_name"
    t.string "resume_content_type"
    t.bigint "resume_file_size"
    t.datetime "resume_updated_at", precision: nil
    t.string "sample_writing_file_name"
    t.string "sample_writing_content_type"
    t.bigint "sample_writing_file_size"
    t.datetime "sample_writing_updated_at", precision: nil
    t.string "grade"
    t.integer "user_id"
    t.text "editor_revision"
    t.text "editor_feedback"
    t.text "editor_pitches"
    t.string "kind"
    t.string "rejected_writer_at"
    t.string "rejected_editor_at"
    t.integer "invitation_id"
  end

  create_table "badges", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.string "level"
    t.string "color"
    t.integer "user_id"
    t.boolean "activated"
    t.string "kind"
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.string "slug"
    t.string "image_file_name"
    t.string "image_content_type"
    t.bigint "image_file_size"
    t.datetime "image_updated_at", precision: nil
    t.string "description"
    t.boolean "archive"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "ckeditor_assets", id: :serial, force: :cascade do |t|
    t.string "data_file_name", null: false
    t.string "data_content_type"
    t.integer "data_file_size"
    t.string "data_fingerprint"
    t.string "type", limit: 30
    t.integer "width"
    t.integer "height"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["type"], name: "index_ckeditor_assets_on_type"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "text"
    t.integer "user_id"
    t.integer "post_id"
    t.integer "comment_id"
    t.text "response_to"
    t.string "full_name"
    t.string "email"
    t.boolean "subscribed"
    t.string "cookie"
    t.boolean "public"
  end

  create_table "constants", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.string "value"
    t.string "slug"
  end

  create_table "feedback_givens", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "feedback_id"
    t.integer "review_id"
  end

  create_table "feedbacks", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "editor_descr"
    t.text "review_descr"
    t.boolean "archive"
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at", precision: nil
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "impressions", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "Impression_count"
  end

  create_table "invitations", force: :cascade do |t|
    t.integer "impressions", default: 0
    t.string "status"
    t.integer "user_id"
    t.string "email"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "apply_id"
    t.string "token"
    t.datetime "alert_viewed_at", precision: nil
  end

  create_table "mailers", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "newsletters", force: :cascade do |t|
    t.text "message"
    t.string "kind"
    t.string "background_color"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "ready"
    t.datetime "sent_at", precision: nil
    t.integer "user_id"
    t.string "hero_image_file_name"
    t.string "hero_image_content_type"
    t.bigint "hero_image_file_size"
    t.datetime "hero_image_updated_at", precision: nil
  end

  create_table "outreaches", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "partner_email"
    t.string "partner_name"
    t.integer "user_id"
    t.text "email_draft"
    t.boolean "sent"
    t.text "sponsored_article_pitch"
    t.decimal "sponsored_article_cost"
  end

  create_table "pay_charges", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "subscription_id"
    t.string "processor_id", null: false
    t.integer "amount", null: false
    t.string "currency"
    t.integer "application_fee_amount"
    t.integer "amount_refunded"
    t.jsonb "metadata"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "processor_id"], name: "index_pay_charges_on_customer_id_and_processor_id", unique: true
    t.index ["subscription_id"], name: "index_pay_charges_on_subscription_id"
  end

  create_table "pay_customers", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "processor", null: false
    t.string "processor_id"
    t.boolean "default"
    t.jsonb "data"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id", "deleted_at", "default"], name: "pay_customer_owner_index"
    t.index ["processor", "processor_id"], name: "index_pay_customers_on_processor_and_processor_id", unique: true
  end

  create_table "pay_merchants", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "processor", null: false
    t.string "processor_id"
    t.boolean "default"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id", "processor"], name: "index_pay_merchants_on_owner_type_and_owner_id_and_processor"
  end

  create_table "pay_payment_methods", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "processor_id", null: false
    t.boolean "default"
    t.string "type"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "processor_id"], name: "index_pay_payment_methods_on_customer_id_and_processor_id", unique: true
  end

  create_table "pay_subscriptions", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "name", null: false
    t.string "processor_id", null: false
    t.string "processor_plan", null: false
    t.integer "quantity", default: 1, null: false
    t.string "status", null: false
    t.datetime "trial_ends_at", precision: nil
    t.datetime "ends_at", precision: nil
    t.decimal "application_fee_percent", precision: 8, scale: 2
    t.jsonb "metadata"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "processor_id"], name: "index_pay_subscriptions_on_customer_id_and_processor_id", unique: true
  end

  create_table "pay_webhooks", force: :cascade do |t|
    t.string "processor"
    t.string "event_type"
    t.jsonb "event"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pitches", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "slug"
    t.string "thumbnail_file_name"
    t.string "thumbnail_content_type"
    t.bigint "thumbnail_file_size"
    t.datetime "thumbnail_updated_at", precision: nil
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
    t.datetime "claimed_at", precision: nil
    t.string "contact_email"
    t.string "influencer_social_media"
    t.string "platform_to_share"
    t.string "interview_kind"
    t.string "following_level"
    t.string "admin_notes"
    t.index ["slug"], name: "index_pitches_on_slug", unique: true
    t.index ["updated_at"], name: "index_pitches_on_updated_at"
  end

  create_table "posts", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "link"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.bigint "thumbnail_file_size"
    t.datetime "thumbnail_updated_at", precision: nil
    t.integer "post_impressions", default: 0
    t.integer "ranking"
    t.string "collaboration"
    t.integer "pitch_id"
    t.datetime "publish_at", precision: nil
    t.integer "feedback_list", default: [], array: true
    t.boolean "sharing"
    t.boolean "editor_can_make_changes"
    t.datetime "promoting_until", precision: nil
    t.integer "partner_id"
    t.boolean "featured"
    t.datetime "deadline_at", precision: nil
    t.integer "newsletter_id"
    t.datetime "shared_at", precision: nil
    t.string "thumbnail_credits"
    t.boolean "show_disclosure"
    t.boolean "turn_off_caps"
    t.string "shareable_token"
    t.index ["post_impressions"], name: "index_posts_on_post_impressions"
    t.index ["publish_at"], name: "index_posts_on_publish_at"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "link"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "slug"
    t.index ["slug"], name: "index_projects_on_slug", unique: true
  end

  create_table "reviews", id: :serial, force: :cascade do |t|
    t.integer "post_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "status", default: "In Progress"
    t.boolean "active"
    t.integer "editor_id"
    t.text "notes"
    t.integer "feedback", default: [], array: true
    t.datetime "editor_claimed_review_at", precision: nil
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.bigint "profile_file_size"
    t.datetime "profile_updated_at", precision: nil
    t.boolean "editor"
    t.string "full_name"
    t.string "slug"
    t.integer "posts_count"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.string "category"
    t.string "nickname"
    t.integer "monthly_views"
    t.boolean "submitted_profile"
    t.boolean "approved_profile"
    t.boolean "bi_monthly_assignment"
    t.boolean "do_not_send_emails"
    t.datetime "last_saw_pitches", precision: nil
    t.datetime "last_saw_peer_feedback", precision: nil
    t.datetime "last_saw_writer_applications", precision: nil
    t.datetime "last_saw_editor_dashboard", precision: nil
    t.datetime "last_saw_community", precision: nil
    t.integer "points", default: 0
    t.boolean "partner"
    t.integer "onboarding_claimed_pitch_id"
    t.boolean "read_pitches"
    t.boolean "read_articles"
    t.boolean "read_images"
    t.string "last_saw_new_writer_dashboard"
    t.string "last_saw_writer_dashboard"
    t.string "became_an_editor"
    t.boolean "completed_editor_onboarding"
    t.datetime "missed_editor_deadline", precision: nil
    t.boolean "notify_of_new_review"
    t.integer "extensions", default: 1
    t.boolean "has_newsletter_permissions"
    t.integer "promotions", default: 0
    t.boolean "skip_assignment"
    t.boolean "marketer"
    t.string "city"
    t.string "country"
    t.datetime "last_saw_interviews"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["full_name"], name: "index_users_on_full_name"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "pay_charges", "pay_customers", column: "customer_id"
  add_foreign_key "pay_charges", "pay_subscriptions", column: "subscription_id"
  add_foreign_key "pay_payment_methods", "pay_customers", column: "customer_id"
  add_foreign_key "pay_subscriptions", "pay_customers", column: "customer_id"
end

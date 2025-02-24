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

ActiveRecord::Schema[8.0].define(version: 2025_02_21_100342) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"

  create_table "accounts", force: :cascade do |t|
    t.jsonb "metadata", default: {}, null: false
    t.jsonb "settings", default: {}, null: false
    t.citext "twilio_account_sid"
    t.citext "somleng_account_sid"
    t.string "twilio_auth_token"
    t.string "somleng_auth_token"
    t.integer "permissions", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "call_flow_logic", null: false
    t.string "platform_provider_name"
    t.string "somleng_api_host"
    t.string "somleng_api_base_url"
    t.index ["somleng_account_sid"], name: "index_accounts_on_somleng_account_sid", unique: true
    t.index ["twilio_account_sid"], name: "index_accounts_on_twilio_account_sid", unique: true
  end

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

  create_table "alerts", force: :cascade do |t|
    t.bigint "broadcast_id", null: false
    t.bigint "beneficiary_id"
    t.bigint "callout_population_id"
    t.string "call_flow_logic", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "delivery_attempts_count", default: 0, null: false
    t.string "phone_number", null: false
    t.string "status", null: false
    t.index ["beneficiary_id"], name: "index_alerts_on_beneficiary_id"
    t.index ["broadcast_id", "beneficiary_id"], name: "index_alerts_on_broadcast_id_and_beneficiary_id", unique: true
    t.index ["broadcast_id"], name: "index_alerts_on_broadcast_id"
    t.index ["callout_population_id"], name: "index_alerts_on_callout_population_id"
  end

  create_table "batch_operations", force: :cascade do |t|
    t.bigint "broadcast_id"
    t.jsonb "parameters", default: {}, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "status", null: false
    t.string "type", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_batch_operations_on_account_id"
    t.index ["broadcast_id"], name: "index_batch_operations_on_broadcast_id"
    t.index ["created_at"], name: "index_batch_operations_on_created_at"
    t.index ["status"], name: "index_batch_operations_on_status"
    t.index ["updated_at"], name: "index_batch_operations_on_updated_at"
  end

  create_table "beneficiaries", force: :cascade do |t|
    t.string "phone_number", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "account_id", null: false
    t.string "status", default: "active", null: false
    t.string "language_code"
    t.string "gender"
    t.date "date_of_birth"
    t.citext "iso_country_code", null: false
    t.string "disability_status"
    t.index ["account_id", "date_of_birth"], name: "index_beneficiaries_on_account_id_and_date_of_birth"
    t.index ["account_id", "disability_status"], name: "index_beneficiaries_on_account_id_and_disability_status"
    t.index ["account_id", "gender"], name: "index_beneficiaries_on_account_id_and_gender"
    t.index ["account_id", "iso_country_code"], name: "index_beneficiaries_on_account_id_and_iso_country_code"
    t.index ["account_id", "language_code"], name: "index_beneficiaries_on_account_id_and_language_code"
    t.index ["account_id", "phone_number"], name: "index_beneficiaries_on_account_id_and_phone_number", unique: true
    t.index ["account_id", "status"], name: "index_beneficiaries_on_account_id_and_status", where: "((status)::text = 'active'::text)"
    t.index ["account_id"], name: "index_beneficiaries_on_account_id"
    t.index ["created_at"], name: "index_beneficiaries_on_created_at"
    t.index ["updated_at"], name: "index_beneficiaries_on_updated_at"
  end

  create_table "beneficiary_addresses", force: :cascade do |t|
    t.bigint "beneficiary_id", null: false
    t.citext "iso_region_code", null: false
    t.citext "administrative_division_level_2_code"
    t.citext "administrative_division_level_2_name"
    t.citext "administrative_division_level_3_code"
    t.citext "administrative_division_level_3_name"
    t.citext "administrative_division_level_4_code"
    t.citext "administrative_division_level_4_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["beneficiary_id", "iso_region_code", "administrative_division_level_2_code", "administrative_division_level_3_code", "administrative_division_level_4_code"], name: "idx_on_beneficiary_id_iso_region_code_administrativ_c45be0885e"
    t.index ["beneficiary_id", "iso_region_code", "administrative_division_level_2_name", "administrative_division_level_3_name", "administrative_division_level_4_name"], name: "idx_on_beneficiary_id_iso_region_code_administrativ_396f86096a"
    t.index ["beneficiary_id"], name: "index_beneficiary_addresses_on_beneficiary_id"
  end

  create_table "broadcasts", force: :cascade do |t|
    t.string "status", null: false
    t.string "call_flow_logic", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "account_id", null: false
    t.string "audio_url"
    t.jsonb "settings", default: {}, null: false
    t.bigint "created_by_id"
    t.string "channel", null: false
    t.jsonb "beneficiary_filter", default: {}, null: false
    t.index ["account_id"], name: "index_broadcasts_on_account_id"
    t.index ["created_by_id"], name: "index_broadcasts_on_created_by_id"
    t.index ["status"], name: "index_broadcasts_on_status"
  end

  create_table "delivery_attempts", force: :cascade do |t|
    t.bigint "alert_id"
    t.bigint "beneficiary_id"
    t.string "status", null: false
    t.string "phone_number", null: false
    t.string "remote_call_id"
    t.string "remote_status"
    t.string "remote_direction"
    t.text "remote_error_message"
    t.jsonb "metadata", default: {}, null: false
    t.jsonb "remote_response", default: {}, null: false
    t.jsonb "remote_queue_response", default: {}, null: false
    t.string "call_flow_logic", null: false
    t.datetime "remotely_queued_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "duration", default: 0, null: false
    t.integer "lock_version", default: 0, null: false
    t.bigint "account_id", null: false
    t.datetime "remote_status_fetch_queued_at", precision: nil
    t.bigint "broadcast_id"
    t.index ["account_id"], name: "index_delivery_attempts_on_account_id"
    t.index ["alert_id"], name: "index_delivery_attempts_on_alert_id"
    t.index ["beneficiary_id"], name: "index_delivery_attempts_on_beneficiary_id"
    t.index ["broadcast_id", "status"], name: "index_delivery_attempts_on_broadcast_id_and_status"
    t.index ["broadcast_id"], name: "index_delivery_attempts_on_broadcast_id"
    t.index ["created_at"], name: "index_delivery_attempts_on_created_at"
    t.index ["phone_number"], name: "index_delivery_attempts_on_phone_number"
    t.index ["remote_call_id"], name: "index_delivery_attempts_on_remote_call_id", unique: true
    t.index ["remote_status_fetch_queued_at"], name: "index_delivery_attempts_on_remote_status_fetch_queued_at"
    t.index ["remotely_queued_at"], name: "index_delivery_attempts_on_remotely_queued_at"
    t.index ["status"], name: "index_delivery_attempts_on_status"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "created_by_id", null: false
    t.jsonb "metadata", default: {}, null: false
    t.bigint "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.bigint "permissions", default: 0, null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["created_by_id"], name: "index_oauth_access_tokens_on_created_by_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.bigint "owner_id", null: false
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["owner_id"], name: "index_oauth_applications_on_owner_id"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "pghero_query_stats", force: :cascade do |t|
    t.text "database"
    t.text "user"
    t.text "query"
    t.bigint "query_hash"
    t.float "total_time"
    t.bigint "calls"
    t.datetime "captured_at", precision: nil
    t.index ["database", "captured_at"], name: "index_pghero_query_stats_on_database_and_captured_at"
  end

  create_table "recordings", force: :cascade do |t|
    t.bigint "delivery_attempt_id", null: false
    t.bigint "account_id", null: false
    t.bigint "beneficiary_id", null: false
    t.string "external_recording_id", null: false
    t.string "external_recording_url", null: false
    t.integer "duration", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_recordings_on_account_id"
    t.index ["beneficiary_id"], name: "index_recordings_on_beneficiary_id"
    t.index ["created_at"], name: "index_recordings_on_created_at"
    t.index ["delivery_attempt_id"], name: "index_recordings_on_delivery_attempt_id"
  end

  create_table "remote_phone_call_events", force: :cascade do |t|
    t.bigint "delivery_attempt_id", null: false
    t.jsonb "details", default: {}, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "remote_call_id", null: false
    t.string "remote_direction", null: false
    t.string "call_flow_logic", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "call_duration", default: 0, null: false
    t.index ["delivery_attempt_id"], name: "index_remote_phone_call_events_on_delivery_attempt_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.integer "invitation_limit"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "locale", default: "en", null: false
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "alerts", "batch_operations", column: "callout_population_id"
  add_foreign_key "alerts", "beneficiaries", on_delete: :nullify
  add_foreign_key "alerts", "broadcasts"
  add_foreign_key "batch_operations", "accounts"
  add_foreign_key "batch_operations", "broadcasts"
  add_foreign_key "beneficiaries", "accounts"
  add_foreign_key "beneficiary_addresses", "beneficiaries", on_delete: :cascade
  add_foreign_key "broadcasts", "accounts"
  add_foreign_key "broadcasts", "users", column: "created_by_id"
  add_foreign_key "delivery_attempts", "accounts"
  add_foreign_key "delivery_attempts", "alerts"
  add_foreign_key "delivery_attempts", "beneficiaries", on_delete: :nullify
  add_foreign_key "delivery_attempts", "broadcasts"
  add_foreign_key "oauth_access_grants", "accounts", column: "resource_owner_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "accounts", column: "created_by_id"
  add_foreign_key "oauth_access_tokens", "accounts", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_applications", "accounts", column: "owner_id"
  add_foreign_key "recordings", "accounts"
  add_foreign_key "recordings", "beneficiaries"
  add_foreign_key "recordings", "delivery_attempts"
  add_foreign_key "remote_phone_call_events", "delivery_attempts"
  add_foreign_key "users", "accounts"
  add_foreign_key "users", "users", column: "invited_by_id"
end

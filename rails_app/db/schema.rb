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

ActiveRecord::Schema[8.0].define(version: 2026_04_15_120008) do
  create_table "admin_events", force: :cascade do |t|
    t.string "action", null: false
    t.string "actor_identifier", null: false
    t.integer "organization_id"
    t.integer "draw_id"
    t.integer "bank_account_id"
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_admin_events_on_action"
    t.index ["bank_account_id"], name: "index_admin_events_on_bank_account_id"
    t.index ["created_at"], name: "index_admin_events_on_created_at"
    t.index ["draw_id"], name: "index_admin_events_on_draw_id"
    t.index ["organization_id"], name: "index_admin_events_on_organization_id"
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.string "display_name", null: false
    t.string "mask_last4", null: false
    t.string "verification_status", default: "incomplete", null: false
    t.string "verification_method"
    t.string "legal_name_on_account"
    t.string "account_type", default: "checking", null: false
    t.string "routing_number"
    t.string "account_number"
    t.string "plaid_item_id"
    t.string "plaid_account_id"
    t.datetime "micro_deposit_sent_at"
    t.integer "micro_deposit_a_cents"
    t.integer "micro_deposit_b_cents"
    t.integer "micro_deposit_attempts", default: 0, null: false
    t.string "failure_reason"
    t.string "account_fingerprint"
    t.boolean "primary_for_disbursement", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "account_fingerprint"], name: "index_bank_accounts_on_org_and_fingerprint", unique: true
    t.index ["organization_id"], name: "index_bank_accounts_on_organization_id"
  end

  create_table "draws", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "bank_account_id", null: false
    t.integer "amount_cents", null: false
    t.integer "term_months", null: false
    t.string "status", default: "processing", null: false
    t.datetime "funded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "decline_reason"
    t.text "operator_notes"
    t.string "internal_decline_code"
    t.index ["bank_account_id"], name: "index_draws_on_bank_account_id"
    t.index ["organization_id"], name: "index_draws_on_organization_id"
  end

  create_table "installments", force: :cascade do |t|
    t.integer "draw_id", null: false
    t.integer "sequence", null: false
    t.date "due_on", null: false
    t.integer "amount_cents", null: false
    t.integer "principal_cents", null: false
    t.integer "interest_cents", default: 0, null: false
    t.string "status", default: "scheduled", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["draw_id", "sequence"], name: "index_installments_on_draw_id_and_sequence", unique: true
    t.index ["draw_id"], name: "index_installments_on_draw_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.integer "credit_limit_cents", default: 0, null: false
    t.integer "available_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "importer_external_id"
    t.string "portal_status", default: "active", null: false
    t.index ["importer_external_id"], name: "index_organizations_on_importer_external_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
  end

  add_foreign_key "admin_events", "bank_accounts"
  add_foreign_key "admin_events", "draws"
  add_foreign_key "admin_events", "organizations"
  add_foreign_key "bank_accounts", "organizations"
  add_foreign_key "draws", "bank_accounts"
  add_foreign_key "draws", "organizations"
  add_foreign_key "installments", "draws"
  add_foreign_key "users", "organizations"
end

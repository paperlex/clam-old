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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111117053959) do

  create_table "cla_templates", :force => true do |t|
    t.string   "name"
    t.string   "slaw_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "user_form"
    t.text     "owner_form"
  end

  create_table "contracts", :force => true do |t|
    t.string   "uuid"
    t.integer  "user_id"
    t.integer  "contributor_license_agreement_id"
    t.text     "responses"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contributor_license_agreements", :force => true do |t|
    t.integer  "user_id"
    t.string   "repo_name"
    t.integer  "cla_template_id"
    t.string   "company_name"
    t.text     "address"
    t.string   "legal_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "org_name"
    t.text     "owner_responses"
  end

  create_table "signatures", :force => true do |t|
    t.integer  "contributor_license_agreement_id"
    t.integer  "user_id"
    t.integer  "contract_id"
    t.string   "contract_uuid"
    t.string   "signature_uuid"
    t.string   "identity_verification_method"
    t.string   "identity_verification_value"
    t.string   "callback_signature_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "github_id"
    t.string   "github_login"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "github_email"
  end

end

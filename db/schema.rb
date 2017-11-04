# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20161211193734) do

  create_table "admins", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "activation_digest"
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
  end

  create_table "artist_surveys", force: :cascade do |t|
    t.boolean  "has_attended_firefly"
    t.string   "has_attended_firefly_desc"
    t.boolean  "has_attended_regional"
    t.string   "has_attended_regional_desc"
    t.boolean  "has_attended_bm"
    t.string   "has_attended_bm_desc"
    t.boolean  "can_use_as_example"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "artist_id"
  end

  add_index "artist_surveys", ["artist_id"], name: "index_artist_surveys_on_artist_id"

  create_table "artists", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "contact_name"
    t.string   "contact_phone"
    t.string   "contact_street"
    t.string   "contact_city"
    t.string   "contact_state"
    t.string   "contact_country"
    t.string   "activation_digest"
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.string   "contact_zipcode"
  end

  create_table "grant_submissions", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "grant_id"
    t.integer  "artist_id"
    t.string   "proposal"
    t.integer  "requested_funding_dollars"
    t.integer  "granted_funding_dollars"
    t.boolean  "funding_decision"
    t.string   "questions"
    t.string   "answers"
    t.datetime "questions_updated_at"
    t.datetime "answers_updated_at"
  end

  add_index "grant_submissions", ["artist_id"], name: "index_grant_submissions_on_artist_id"
  add_index "grant_submissions", ["grant_id"], name: "index_grant_submissions_on_grant_id"

  create_table "grants", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "max_funding_dollars"
    t.datetime "submit_start"
    t.datetime "submit_end"
    t.datetime "vote_start"
    t.datetime "vote_end"
    t.datetime "meeting_one"
    t.datetime "meeting_two"
    t.boolean  "hidden",              default: false
  end

  create_table "grants_voters", force: :cascade do |t|
    t.integer  "voter_id"
    t.integer  "grant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "proposals", force: :cascade do |t|
    t.string  "file"
    t.integer "grant_submission_id"
  end

  add_index "proposals", ["grant_submission_id"], name: "index_proposals_on_grant_submission_id"

  create_table "voter_submission_assignments", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "voter_id"
    t.integer  "grant_submission_id"
  end

  create_table "voter_surveys", force: :cascade do |t|
    t.boolean  "has_attended_firefly"
    t.boolean  "not_applying_this_year"
    t.boolean  "will_read"
    t.boolean  "will_meet"
    t.boolean  "has_been_voter"
    t.boolean  "has_participated_other"
    t.boolean  "has_received_grant"
    t.boolean  "has_received_other_grant"
    t.integer  "how_many_fireflies"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "voter_id"
    t.boolean  "signed_agreement",         default: false
  end

  add_index "voter_surveys", ["voter_id"], name: "index_voter_surveys_on_voter_id"

  create_table "voters", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.boolean  "verified"
    t.string   "activation_digest"
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "score_t"
    t.integer  "score_c"
    t.integer  "score_f"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "voter_id"
    t.integer  "grant_submission_id"
  end

end

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

ActiveRecord::Schema.define(version: 20130526211001) do

  create_table "conferences", force: true do |t|
    t.string   "name"
    t.string   "contact_name"
    t.string   "contact_email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: true do |t|
    t.integer  "conference_id"
    t.string   "name",                                       null: false
    t.date     "date",                                       null: false
    t.boolean  "publicly_announced",         default: false, null: false
    t.string   "facebook_event_url"
    t.string   "venue_name"
    t.string   "venue_site_url"
    t.string   "venue_address"
    t.string   "venue_google_map_url"
    t.string   "venue_google_map_image_url"
    t.string   "venue_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: true do |t|
    t.integer  "event_id",   null: false
    t.integer  "speaker_id"
    t.string   "start_at",   null: false
    t.string   "title",      null: false
    t.string   "slides_url"
    t.string   "video_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "speakers", force: true do |t|
    t.string   "name",          null: false
    t.text     "description"
    t.string   "personal_site"
    t.string   "company"
    t.string   "company_site"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "events", "conferences", :name => "events_conference_id_fk"

  add_foreign_key "sessions", "events", :name => "sessions_event_id_fk"
  add_foreign_key "sessions", "speakers", :name => "sessions_speaker_id_fk"

end
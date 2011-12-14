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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110914073447) do

  create_table "actions", :force => true do |t|
    t.string   "operation"
    t.string   "destination"
    t.integer  "filter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "filters", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "glue",       :default => "and"
  end

  create_table "locales", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.string   "subject"
    t.text     "body"
    t.string   "priority"
    t.string   "message_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rules", :force => true do |t|
    t.string   "section"
    t.string   "part"
    t.string   "substance"
    t.integer  "filter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "translations", :force => true do |t|
    t.integer  "locale_id"
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.integer  "roles_mask"
  end

end

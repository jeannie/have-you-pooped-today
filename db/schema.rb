# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090104060736) do

  create_table "facebook_users", :force => true do |t|
    t.integer  "facebook_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "poop_logs", :force => true do |t|
    t.integer  "facebook_user_id"
    t.boolean  "pooped"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ppp_indices", :force => true do |t|
    t.integer  "facebook_user_id"
    t.integer  "poop_count"
    t.float    "ppp_index"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

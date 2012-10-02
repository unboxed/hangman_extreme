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

ActiveRecord::Schema.define(:version => 20121002101957) do

  create_table "games", :force => true do |t|
    t.string   "word"
    t.text     "choices"
    t.integer  "user_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "completed",  :default => false
    t.integer  "score"
  end

  add_index "games", ["created_at"], :name => "index_games_on_created_at"
  add_index "games", ["score"], :name => "index_games_on_score"
  add_index "games", ["user_id"], :name => "index_games_on_user_id"

  create_table "settings", :force => true do |t|
    t.string   "var",                       :null => false
    t.text     "value"
    t.integer  "target_id"
    t.string   "target_type", :limit => 30
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "settings", ["target_type", "target_id", "var"], :name => "index_settings_on_target_type_and_target_id_and_var", :unique => true

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "uid"
    t.string   "provider"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "weekly_rating",        :default => 0
    t.integer  "monthly_rating",       :default => 0
    t.integer  "yearly_rating",        :default => 0
    t.string   "utma"
    t.integer  "weekly_precision",     :default => 0
    t.integer  "monthly_precision",    :default => 0
    t.integer  "games_won_this_week",  :default => 0
    t.integer  "games_won_this_month", :default => 0
    t.integer  "daily_rating",         :default => 0
    t.integer  "daily_precision",      :default => 0
    t.integer  "games_won_today",      :default => 0
  end

  add_index "users", ["daily_precision"], :name => "index_users_on_daily_precision"
  add_index "users", ["daily_rating"], :name => "index_users_on_daily_rating"
  add_index "users", ["games_won_this_month"], :name => "index_users_on_games_won_this_month"
  add_index "users", ["games_won_this_week"], :name => "index_users_on_games_won_this_week"
  add_index "users", ["games_won_today"], :name => "index_users_on_games_won_today"
  add_index "users", ["monthly_precision"], :name => "index_users_on_monthly_precision"
  add_index "users", ["monthly_rating"], :name => "index_users_on_monthly_rating"
  add_index "users", ["uid", "provider"], :name => "index_users_on_uid_and_provider"
  add_index "users", ["weekly_precision"], :name => "index_users_on_weekly_precision"
  add_index "users", ["weekly_rating"], :name => "index_users_on_weekly_rating"
  add_index "users", ["yearly_rating"], :name => "index_users_on_yearly_rating"

end

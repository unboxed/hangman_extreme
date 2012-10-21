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

ActiveRecord::Schema.define(:version => 20121018104819) do

  create_table "games", :force => true do |t|
    t.string   "word"
    t.text     "choices"
    t.integer  "user_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "completed",     :default => false
    t.integer  "score"
    t.boolean  "clue_revealed", :default => false, :null => false
  end

  add_index "games", ["created_at"], :name => "index_games_on_created_at"
  add_index "games", ["score"], :name => "index_games_on_score"
  add_index "games", ["user_id"], :name => "index_games_on_user_id"

  create_table "purchase_transactions", :force => true do |t|
    t.integer  "user_id"
    t.string   "product_id",          :null => false
    t.string   "product_name",        :null => false
    t.text     "product_description"
    t.integer  "moola_amount",        :null => false
    t.string   "currency_amount",     :null => false
    t.string   "ref"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "purchase_transactions", ["user_id"], :name => "index_purchase_transactions_on_user_id"

  create_table "redeem_winnings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "prize_amount"
    t.string   "prize_type"
    t.string   "state"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "redeem_winnings", ["user_id"], :name => "index_redeem_winnings_on_user_id"

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
    t.text     "name"
    t.string   "uid"
    t.string   "provider"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "weekly_rating",     :default => 0
    t.integer  "monthly_rating",    :default => 0
    t.integer  "yearly_rating",     :default => 0
    t.integer  "weekly_precision",  :default => 0
    t.integer  "monthly_precision", :default => 0
    t.integer  "weekly_wins",       :default => 0
    t.integer  "monthly_wins",      :default => 0
    t.integer  "daily_rating",      :default => 0
    t.integer  "daily_precision",   :default => 0
    t.integer  "daily_wins",        :default => 0
    t.string   "real_name"
    t.string   "mobile_number"
    t.string   "email"
    t.integer  "clue_points",       :default => 2, :null => false
    t.integer  "prize_points",      :default => 0, :null => false
    t.string   "login"
  end

  add_index "users", ["created_at"], :name => "index_users_on_created_at"
  add_index "users", ["daily_precision"], :name => "index_users_on_daily_precision"
  add_index "users", ["daily_rating"], :name => "index_users_on_daily_rating"
  add_index "users", ["daily_wins"], :name => "index_users_on_games_won_today"
  add_index "users", ["monthly_precision"], :name => "index_users_on_monthly_precision"
  add_index "users", ["monthly_rating"], :name => "index_users_on_monthly_rating"
  add_index "users", ["monthly_wins"], :name => "index_users_on_games_won_this_month"
  add_index "users", ["uid", "provider"], :name => "index_users_on_uid_and_provider"
  add_index "users", ["updated_at"], :name => "index_users_on_updated_at"
  add_index "users", ["weekly_precision"], :name => "index_users_on_weekly_precision"
  add_index "users", ["weekly_rating"], :name => "index_users_on_weekly_rating"
  add_index "users", ["weekly_wins"], :name => "index_users_on_games_won_this_week"
  add_index "users", ["yearly_rating"], :name => "index_users_on_yearly_rating"

  create_table "winners", :force => true do |t|
    t.integer  "user_id"
    t.string   "reason"
    t.integer  "amount"
    t.string   "period"
    t.date     "end_of_period_on"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "winners", ["user_id"], :name => "index_winners_on_user_id"

end

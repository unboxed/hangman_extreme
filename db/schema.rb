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

ActiveRecord::Schema.define(version: 20140117152950) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "airtime_vouchers", force: true do |t|
    t.integer  "redeem_winning_id"
    t.integer  "_deprecated_user_id"
    t.string   "freepaid_refno"
    t.string   "network"
    t.string   "pin"
    t.float    "sellvalue"
    t.text     "response"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_account_id"
  end

  add_index "airtime_vouchers", ["_deprecated_user_id"], name: "index_airtime_vouchers_on__deprecated_user_id", using: :btree
  add_index "airtime_vouchers", ["created_at"], name: "index_airtime_vouchers_on_created_at", using: :btree
  add_index "airtime_vouchers", ["redeem_winning_id"], name: "index_airtime_vouchers_on_redeem_winning_id", using: :btree
  add_index "airtime_vouchers", ["updated_at"], name: "index_airtime_vouchers_on_updated_at", using: :btree

  create_table "badge_trackers", force: true do |t|
    t.integer  "user_id"
    t.integer  "clues_revealed", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "badges", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "badges", ["user_id"], name: "index_badges_on_user_id", using: :btree

  create_table "feedback", force: true do |t|
    t.integer  "user_id"
    t.string   "subject"
    t.text     "message"
    t.string   "support_type", default: "suggestion"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feedback", ["user_id"], name: "index_feedback_on_user_id", using: :btree

  create_table "games", force: true do |t|
    t.string   "word"
    t.text     "choices"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "completed",               default: false
    t.integer  "score"
    t.boolean  "clue_revealed",           default: false, null: false
    t.integer  "completed_attempts_left"
  end

  add_index "games", ["created_at"], name: "index_games_on_created_at", using: :btree
  add_index "games", ["score"], name: "index_games_on_score", using: :btree
  add_index "games", ["user_id"], name: "index_games_on_user_id", using: :btree

  create_table "purchase_transactions", force: true do |t|
    t.integer  "_deprecated_user_id"
    t.string   "product_id",          null: false
    t.string   "product_name",        null: false
    t.text     "product_description"
    t.integer  "moola_amount",        null: false
    t.string   "currency_amount",     null: false
    t.string   "ref"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_account_id"
  end

  add_index "purchase_transactions", ["_deprecated_user_id"], name: "index_purchase_transactions_on__deprecated_user_id", using: :btree

  create_table "redeem_winnings", force: true do |t|
    t.integer  "_deprecated_user_id"
    t.integer  "prize_amount"
    t.string   "prize_type"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "mxit_money_reference"
    t.integer  "user_account_id"
  end

  add_index "redeem_winnings", ["_deprecated_user_id"], name: "index_redeem_winnings_on__deprecated_user_id", using: :btree

  create_table "user_accounts", force: true do |t|
    t.string   "uid",                        null: false
    t.string   "provider",                   null: false
    t.string   "mxit_login"
    t.string   "real_name"
    t.string   "mobile_number"
    t.string   "email"
    t.integer  "credits",       default: 24
    t.integer  "prize_points",  default: 0
    t.integer  "lock_version",  default: 0,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.text     "name"
    t.string   "uid"
    t.string   "provider"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "weekly_rating",             default: 0
    t.integer  "yearly_rating",             default: 0
    t.integer  "weekly_streak",             default: 0
    t.integer  "daily_rating",              default: 0
    t.integer  "daily_streak",              default: 0
    t.string   "_deprecated_real_name"
    t.string   "_deprecated_mobile_number"
    t.string   "_deprecated_email"
    t.integer  "_deprecated_credits",       default: 24,   null: false
    t.integer  "_deprecated_prize_points",  default: 0,    null: false
    t.string   "_deprecated_login"
    t.integer  "lock_version",              default: 0,    null: false
    t.integer  "current_daily_streak",      default: 0,    null: false
    t.integer  "current_weekly_streak",     default: 0,    null: false
    t.integer  "daily_wins",                default: 0,    null: false
    t.integer  "weekly_wins",               default: 0,    null: false
    t.boolean  "show_hangman",              default: true
    t.integer  "winners_count",             default: 0,    null: false
  end

  add_index "users", ["created_at"], name: "index_users_on_created_at", using: :btree
  add_index "users", ["daily_rating"], name: "index_users_on_daily_rating", using: :btree
  add_index "users", ["daily_streak"], name: "index_users_on_daily_streak", using: :btree
  add_index "users", ["uid", "provider"], name: "index_users_on_uid_and_provider", using: :btree
  add_index "users", ["updated_at"], name: "index_users_on_updated_at", using: :btree
  add_index "users", ["weekly_rating"], name: "index_users_on_weekly_rating", using: :btree
  add_index "users", ["weekly_streak"], name: "index_users_on_weekly_streak", using: :btree
  add_index "users", ["yearly_rating"], name: "index_users_on_yearly_rating", using: :btree

  create_table "winners", force: true do |t|
    t.integer  "user_id"
    t.string   "reason"
    t.integer  "amount"
    t.string   "period"
    t.date     "end_of_period_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "winners", ["user_id"], name: "index_winners_on_user_id", using: :btree

end

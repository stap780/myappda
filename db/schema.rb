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

ActiveRecord::Schema.define(version: 2021_01_09_160944) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", id: :serial, force: :cascade do |t|
    t.string "clientid"
    t.string "izb_productid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "companies", id: :serial, force: :cascade do |t|
    t.string "inn"
    t.string "kpp"
    t.string "title"
    t.string "uraddress"
    t.string "factaddress"
    t.string "ogrn"
    t.string "okpo"
    t.string "bik"
    t.string "banktitle"
    t.string "bankaccount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "insints", id: :serial, force: :cascade do |t|
    t.string "subdomen"
    t.string "password"
    t.integer "insalesid"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "inskey"
    t.boolean "status"
  end

  create_table "invoices", id: :serial, force: :cascade do |t|
    t.integer "payplan_id"
    t.string "sum"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payertype"
    t.string "paymenttype"
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "invoice_id"
    t.integer "payplan_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "paymenttype"
    t.datetime "paymentdate"
    t.string "paymentid"
    t.string "subdomain"
  end

  create_table "payplans", id: :serial, force: :cascade do |t|
    t.string "period"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "useraccounts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "shop"
    t.string "insuserid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "name"
    t.string "subdomain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "valid_from"
    t.date "valid_until"
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end

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

ActiveRecord::Schema[7.1].define(version: 2024_10_22_082256) do
  create_schema "demostore"
  create_schema "demostore2"
  create_schema "demostore3"
  create_schema "ketago"
  create_schema "littlebeam"

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abandoned_carts", force: :cascade do |t|
    t.bigint "variant_id", null: false
    t.bigint "client_id", null: false
    t.bigint "product_id", null: false
    t.text "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mycase_id"
    t.index ["client_id"], name: "index_abandoned_carts_on_client_id"
    t.index ["product_id"], name: "index_abandoned_carts_on_product_id"
    t.index ["variant_id"], name: "index_abandoned_carts_on_variant_id"
  end

  create_table "actions", force: :cascade do |t|
    t.string "type"
    t.bigint "event_id"
    t.bigint "template_id"
    t.boolean "pause"
    t.string "pause_time"
    t.boolean "timetable"
    t.string "timetable_time"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["event_id"], name: "index_actions_on_event_id"
    t.index ["template_id"], name: "index_actions_on_template_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "clients", id: :serial, force: :cascade do |t|
    t.string "clientid"
    t.string "izb_productid"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.string "surname"
    t.string "email"
    t.string "phone"
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "email_setups", force: :cascade do |t|
    t.string "address"
    t.integer "port"
    t.string "domain"
    t.string "authentication"
    t.string "user_name"
    t.string "user_password"
    t.boolean "tls"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "event_actions", force: :cascade do |t|
    t.string "channel"
    t.bigint "event_id"
    t.bigint "template_id"
    t.boolean "pause"
    t.string "pause_time"
    t.boolean "timetable"
    t.string "timetable_time"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "operation"
    t.index ["event_id"], name: "index_event_actions_on_event_id"
    t.index ["template_id"], name: "index_event_actions_on_template_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "custom_status"
    t.string "financial_status"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "casetype"
    t.boolean "active", default: true
  end

  create_table "favorite_setups", force: :cascade do |t|
    t.string "title"
    t.string "handle"
    t.string "description"
    t.boolean "status"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "payplan_id"
    t.date "valid_until"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "client_id"
    t.bigint "product_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["client_id"], name: "index_favorites_on_client_id"
    t.index ["product_id"], name: "index_favorites_on_product_id"
  end

  create_table "insints", id: :serial, force: :cascade do |t|
    t.string "subdomen"
    t.string "password"
    t.integer "insales_account_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "inskey"
    t.boolean "status"
  end

  create_table "invoices", id: :serial, force: :cascade do |t|
    t.integer "payplan_id"
    t.string "sum"
    t.string "status"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "payertype"
    t.string "paymenttype"
    t.string "service_handle"
  end

  create_table "lines", force: :cascade do |t|
    t.integer "product_id"
    t.integer "variant_id"
    t.integer "quantity"
    t.decimal "price"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "mycase_id"
  end

  create_table "message_setups", force: :cascade do |t|
    t.string "title"
    t.string "handle"
    t.string "description"
    t.boolean "status"
    t.integer "payplan_id"
    t.date "valid_until"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "product_xml"
  end

  create_table "mycases", force: :cascade do |t|
    t.string "number"
    t.integer "client_id"
    t.string "casetype"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "insales_custom_status_title"
    t.string "insales_financial_status"
    t.integer "insales_order_id"
    t.string "status"
  end

  create_table "order_status_changes", force: :cascade do |t|
    t.integer "client_id"
    t.integer "insales_order_id"
    t.integer "insales_order_number"
    t.string "insales_custom_status_title"
    t.string "insales_financial_status"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "invoice_id"
    t.integer "payplan_id"
    t.string "status"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "paymenttype"
    t.datetime "paymentdate", precision: nil
    t.string "paymentid"
    t.string "subdomain"
  end

  create_table "payplans", id: :serial, force: :cascade do |t|
    t.string "period"
    t.decimal "price"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title"
    t.string "description"
    t.string "service_handle"
    t.string "handle"
  end

  create_table "preorders", force: :cascade do |t|
    t.integer "variant_id"
    t.integer "client_id"
    t.string "status"
    t.integer "product_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "mycase_id"
  end

  create_table "products", force: :cascade do |t|
    t.integer "insid"
    t.string "title"
    t.decimal "price", precision: 8, scale: 2
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "restock"
    t.string "image_link"
  end

  create_table "restock_setups", force: :cascade do |t|
    t.string "title"
    t.string "handle"
    t.string "description"
    t.boolean "status"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "valid_until"
    t.integer "payplan_id"
  end

  create_table "restocks", force: :cascade do |t|
    t.bigint "variant_id"
    t.bigint "client_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "status"
    t.integer "product_id"
    t.integer "mycase_id"
    t.index ["client_id"], name: "index_restocks_on_client_id"
    t.index ["variant_id"], name: "index_restocks_on_variant_id"
  end

  create_table "templates", force: :cascade do |t|
    t.string "title"
    t.string "subject"
    t.string "receiver"
    t.text "content"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "useraccounts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "shop"
    t.string "insuserid"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "name"
    t.string "subdomain"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "valid_from"
    t.date "valid_until"
    t.boolean "admin", default: false
    t.string "phone"
    t.string "role"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "variants", force: :cascade do |t|
    t.integer "insid"
    t.string "sku"
    t.integer "quantity"
    t.decimal "price"
    t.bigint "product_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "restock"
    t.index ["product_id"], name: "index_variants_on_product_id"
  end

  add_foreign_key "abandoned_carts", "clients"
  add_foreign_key "abandoned_carts", "products"
  add_foreign_key "abandoned_carts", "variants"
  add_foreign_key "actions", "events"
  add_foreign_key "actions", "templates"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "event_actions", "events"
  add_foreign_key "event_actions", "templates"
  add_foreign_key "favorites", "clients"
  add_foreign_key "favorites", "products"
  add_foreign_key "restocks", "clients"
  add_foreign_key "restocks", "variants"
  add_foreign_key "variants", "products"
end

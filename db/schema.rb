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

ActiveRecord::Schema.define(version: 20170625213841) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "configs", force: :cascade do |t|
    t.jsonb    "allocation"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.float    "amount",     default: 0.0, null: false
  end

  create_table "executions", force: :cascade do |t|
    t.integer  "config_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["config_id"], name: "index_executions_on_config_id", using: :btree
  end

  create_table "orders", force: :cascade do |t|
    t.string   "uuid",         null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "execution_id"
    t.index ["execution_id"], name: "index_orders_on_execution_id", using: :btree
  end

  add_foreign_key "executions", "configs"
  add_foreign_key "orders", "executions"
end

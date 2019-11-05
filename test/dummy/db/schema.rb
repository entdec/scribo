# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_05_091503) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "accounts", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scribo_contents", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "scribo_site_id"
    t.string "kind", default: "text"
    t.string "path"
    t.text "data"
    t.jsonb "properties", default: {}
    t.uuid "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.integer "lft"
    t.integer "rgt"
    t.integer "depth"
    t.integer "children_count"
    t.string "full_path"
    t.index ["parent_id"], name: "index_scribo_contents_on_parent_id"
    t.index ["scribo_site_id", "full_path"], name: "index_scribo_contents_full_path", unique: true
    t.index ["scribo_site_id", "path"], name: "index_scribo_contents_path"
    t.index ["scribo_site_id"], name: "index_scribo_contents_on_scribo_site_id"
  end

  create_table "scribo_sites", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "scribable_type"
    t.uuid "scribable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "properties", default: {}, null: false
    t.index ["scribable_type", "scribable_id"], name: "index_scribo_sites_on_scribable_type_and_scribable_id"
  end

  add_foreign_key "scribo_contents", "scribo_contents", column: "parent_id"
  add_foreign_key "scribo_contents", "scribo_sites"
end

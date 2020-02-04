class InitialScribo < ActiveRecord::Migration[5.2]
  def change
    return if ActiveRecord::Base.connection.table_exists? 'scribo_contents'

    create_table "scribo_contents", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid "scribo_site_id"
      t.string "kind", default: "text"
      t.string "path"
      t.text "data"
      t.jsonb "properties", default: {}
      t.uuid "parent_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
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
  end
end

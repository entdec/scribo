class CreateScriboContents < ActiveRecord::Migration[5.1]
  def change
    create_table :scribo_contents, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.references :scribo_site, foreign_key: true, type: :uuid
      t.string :kind
      t.string :path
      t.string :content_type
      t.string :filter
      t.string :identifier
      t.string :name
      t.string :title
      t.string :caption
      t.string :breadcrumb
      t.string :keywords
      t.string :description
      t.string :state
      t.binary :data
      t.jsonb :properties
      t.references :layout, index: true, type: :uuid, foreign_key: { to_table: :scribo_contents }
      t.references :parent, index: true, type: :uuid, foreign_key: { to_table: :scribo_contents }
      t.datetime :published_at, default: -> { "(CURRENT_TIMESTAMP AT TIME ZONE 'UTC')" }
      t.timestamps
    end
    add_index :scribo_contents, %w(scribo_site_id path), unique: true, using: :btree, name: 'index_scribo_contents_path'
    add_index :scribo_contents, %w(scribo_site_id identifier), unique: true, using: :btree, name: 'index_scribo_contents_identifier'
    add_index :scribo_contents, %w(parent_id name), unique: true, using: :btree
  end
end

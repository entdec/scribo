class AddFullPathToContent < ActiveRecord::Migration[5.2]
  def change
    add_column :scribo_contents, :full_path, :string
    add_index :scribo_contents, %w(scribo_site_id full_path), unique: true, using: :btree, name: 'index_scribo_contents_full_path'
  end
end

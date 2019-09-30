class RemoveIndicesFromContent < ActiveRecord::Migration[5.2]
  def change
    remove_index :scribo_contents, %w(scribo_site_id path)#, unique: true, using: :btree, name: 'index_scribo_contents_path'
    add_index :scribo_contents, %w(scribo_site_id path), unique: false, using: :btree, name: 'index_scribo_contents_path'
  end
end

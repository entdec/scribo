class RenameSiteToBucket < ActiveRecord::Migration[5.2]
  def change
    rename_column :scribo_contents, :scribo_site_id, :scribo_bucket_id
    rename_table :scribo_sites, :scribo_buckets
  end
end

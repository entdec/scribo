class RenameBucketToSite < ActiveRecord::Migration[5.2]
  def change
    rename_column :scribo_contents, :scribo_bucket_id, :scribo_site_id
    rename_table :scribo_buckets, :scribo_sites
  end
end

class AddSettingsAndTranslationsToBucket < ActiveRecord::Migration[5.2]
  def change
    add_column :scribo_buckets, :settings, :jsonb, null: false, default: {}
    add_column :scribo_buckets, :translations, :jsonb, null: false, default: {}
    add_column :scribo_contents, :translations, :jsonb, null: false, default: {}
    add_column :scribo_contents, :position, :integer
  end
end

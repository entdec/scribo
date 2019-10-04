class RenameSettingsToPropertiesOnSite < ActiveRecord::Migration[5.2]
  def change
    rename_column :scribo_sites, :settings, :properties
  end
end

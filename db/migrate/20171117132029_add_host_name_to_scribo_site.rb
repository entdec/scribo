class AddHostNameToScriboSite < ActiveRecord::Migration[5.1]
  def change
    add_column :scribo_sites, :host_name, :string, default: '.*'
  end
end

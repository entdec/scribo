class RefactorScriboSite < ActiveRecord::Migration[5.1]
  def change
    remove_column :scribo_sites, :host_name, :string, default: '.*'
    add_column :scribo_sites, :purpose, :string, default: 'site'
  end
end

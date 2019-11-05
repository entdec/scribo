class RemoveSitePurposeAndChangeContentDataColumnType < ActiveRecord::Migration[5.2]
  def up
    change_column :scribo_contents, :data, :text, using: "encode(data, 'escape')"
    remove_column :scribo_sites, :purpose, :string, default: 'site'
  end

  def down
    change_column :scribo_contents, :data, :bytea, using: 'data::bytea'
    add_column :scribo_sites, :purpose, :string, default: 'site'
  end
end
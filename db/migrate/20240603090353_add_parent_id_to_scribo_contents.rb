class AddParentIdToScriboContents < ActiveRecord::Migration[7.1]
  def change
    add_column :scribo_contents, :parent_id, :uuid
  end
end

class RemoveParentIdFromScriboContents < ActiveRecord::Migration[6.0]
  def change
    remove_column :scribo_contents, :parent_id
    remove_column :scribo_contents, :lft
    remove_column :scribo_contents, :rgt
    remove_column :scribo_contents, :depth
  end
end

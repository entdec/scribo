class AddAncestryToScriboContents < ActiveRecord::Migration[6.0]
  def change
    add_column :scribo_contents, :ancestry, :text
    add_index :scribo_contents, :ancestry, order: {ancestry: :text_pattern_ops}
    add_column :scribo_contents, :ancestry_depth, :integer,  default: 0
    add_index :scribo_contents, :ancestry_depth
    remove_column :scribo_contents, :children_count
    add_column :scribo_contents, :children_count, :integer,  default: 0
    add_index :scribo_contents, :children_count
    
    Scribo::Content.build_ancestry_from_parent_ids!
  end
end

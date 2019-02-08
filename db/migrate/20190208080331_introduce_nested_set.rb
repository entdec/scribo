class IntroduceNestedSet < ActiveRecord::Migration[5.2]
  def change
    add_column :scribo_contents, :lft, :integer
    add_column :scribo_contents, :rgt, :integer

    # optional fields
    add_column :scribo_contents, :depth, :integer
    add_column :scribo_contents, :children_count, :integer

    remove_column :scribo_contents, :position, :integer

    Scribo::Content.reset_column_information
    Scribo::Content.rebuild!
  end
end

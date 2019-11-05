class RemovePublishedAtFromContents < ActiveRecord::Migration[5.2]
  def change
    remove_column :scribo_contents, :published_at, :datetime
  end
end

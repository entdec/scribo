class RemovePublishedAtFromContents < ActiveRecord::Migration[6.0]
  def change
    remove_column :scribo_contents, :published_at, :datetime
  end
end

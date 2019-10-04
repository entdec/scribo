class RemoveStateFromContent < ActiveRecord::Migration[5.2]
  def change
    remove_column :scribo_contents, :state, :string
  end
end

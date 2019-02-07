class AddPositionToScriboContent < ActiveRecord::Migration[5.2]
  def change
    add_column :scribo_contents, :position, :integer
  end
end

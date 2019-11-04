class ChangePropertiesDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :scribo_contents, :properties, from: nil, to: {}

    Scribo::Content.where(properties: nil).update_all(properties: {})
  end
end

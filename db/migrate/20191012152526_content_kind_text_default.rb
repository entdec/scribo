class ContentKindTextDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :scribo_contents, :kind, 'text'
  end
end

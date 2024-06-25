class CreateScriboContentHierarchies < ActiveRecord::Migration[7.1]
  def change
    create_table :scribo_content_hierarchies, id: false do |t|
      t.uuid :ancestor_id, null: false
      t.uuid :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :scribo_content_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "content_anc_desc_idx"

    add_index :scribo_content_hierarchies, [:descendant_id],
      name: "content_desc_idx"
  end
end
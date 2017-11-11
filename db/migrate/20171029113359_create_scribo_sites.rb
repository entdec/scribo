class CreateScriboSites < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'uuid-ossp'

    create_table :scribo_sites, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :name
      t.references :scribable, polymorphic: true, index: true, type: :uuid

      t.timestamps
    end
  end
end

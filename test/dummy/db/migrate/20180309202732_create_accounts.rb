class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string :name
      t.timestamps
    end
  end
end

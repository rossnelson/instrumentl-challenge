class AddOwners < ActiveRecord::Migration[7.2]
  def change
    create_table(:owners) do |t|
      t.string(:name, null: false)
      t.string(:street)
      t.string(:city)
      t.string(:state)
      t.string(:postal_code)
      t.timestamps
    end
  end
end

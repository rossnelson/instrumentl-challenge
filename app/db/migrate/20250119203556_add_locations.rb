class AddLocations < ActiveRecord::Migration[7.2]
  def change
    create_table(:locations) do |t|
      t.string(:name, null: false)
      t.string(:street)
      t.string(:city)
      t.string(:state)
      t.string(:postal_code)
      t.references(:owner, null: true, foreign_key: true)
      t.timestamps
    end
  end
end

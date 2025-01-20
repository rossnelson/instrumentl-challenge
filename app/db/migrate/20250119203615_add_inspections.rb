class AddInspections < ActiveRecord::Migration[7.2]
  def change
    create_table(:inspections) do |t|
      t.datetime(:occurred_at, null: false)
      t.integer(:score)
      t.references(:inspection_kind, null: false, foreign_key: true)
      t.references(:location, null: false, foreign_key: true)
      t.timestamps
    end
  end
end

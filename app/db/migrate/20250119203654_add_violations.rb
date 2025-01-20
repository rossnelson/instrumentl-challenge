class AddViolations < ActiveRecord::Migration[7.2]
  def change
    create_table(:violations) do |t|
      t.datetime(:occurred_at, null: false)
      t.string(:description, null: false)
      t.references(:violation_kind, null: false, foreign_key: true)
      t.references(:inspection, null: false, foreign_key: true)
      t.references(:location, null: false, foreign_key: true)
      t.references(:risk_category, null: false, foreign_key: true)
      t.timestamps
    end
  end
end

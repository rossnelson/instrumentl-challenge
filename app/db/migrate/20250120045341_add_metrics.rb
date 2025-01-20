class AddMetrics < ActiveRecord::Migration[7.2]
  def change
    create_table :metrics do |t|
      t.date :date, null: false
      t.bigint :location_id, index: true, null: false
      t.string :location_name, null: false
      t.string :street
      t.string :city
      t.string :state
      t.string :postal_code
      t.integer :score_sum, default: 0, null: false
      t.integer :score_count, default: 0, null: false
      t.integer :inspection_count, default: 0, null: false
      t.integer :violation_count, default: 0, null: false
      t.timestamps
    end

    add_index :metrics, [:date, :location_id], unique: true
  end
end

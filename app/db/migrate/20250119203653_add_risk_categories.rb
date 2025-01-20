class AddRiskCategories < ActiveRecord::Migration[7.2]
  def change
    create_table(:risk_categories) do |t|
      t.string(:name, null: false)
      t.timestamps
    end
  end
end

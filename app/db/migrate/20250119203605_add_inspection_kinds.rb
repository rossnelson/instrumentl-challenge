class AddInspectionKinds < ActiveRecord::Migration[7.2]
  def change
    create_table(:inspection_kinds) do |t|
      t.string(:description, null: false)
      t.timestamps
    end
  end
end

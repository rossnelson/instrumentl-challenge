class AddViolationKinds < ActiveRecord::Migration[7.2]
  def change
    create_table(:violation_kinds) do |t|
      t.string(:code, null: false)
      t.timestamps
    end
  end
end

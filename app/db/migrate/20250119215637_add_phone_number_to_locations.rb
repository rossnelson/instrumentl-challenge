class AddPhoneNumberToLocations < ActiveRecord::Migration[7.2]
  def change
    add_column(:locations, :phone_number, :string)
  end
end

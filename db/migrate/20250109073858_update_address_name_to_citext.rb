class UpdateAddressNameToCitext < ActiveRecord::Migration[8.0]
  def change
    change_column :beneficiary_addresses, :administrative_division_level_2_code, :citext
    change_column :beneficiary_addresses, :administrative_division_level_2_name, :citext
    change_column :beneficiary_addresses, :administrative_division_level_3_code, :citext
    change_column :beneficiary_addresses, :administrative_division_level_3_name, :citext
    change_column :beneficiary_addresses, :administrative_division_level_4_code, :citext
    change_column :beneficiary_addresses, :administrative_division_level_4_name, :citext
  end
end

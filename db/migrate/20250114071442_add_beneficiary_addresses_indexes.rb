class AddBeneficiaryAddressesIndexes < ActiveRecord::Migration[8.0]
  def change
    add_index :beneficiary_addresses, [ :beneficiary_id, :iso_region_code, :administrative_division_level_2_code, :administrative_division_level_3_code, :administrative_division_level_4_code ]
    add_index :beneficiary_addresses, [ :beneficiary_id, :iso_region_code, :administrative_division_level_2_name, :administrative_division_level_3_name, :administrative_division_level_4_name ]
  end
end

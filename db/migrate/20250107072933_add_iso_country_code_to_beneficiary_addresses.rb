class AddIsoCountryCodeToBeneficiaryAddresses < ActiveRecord::Migration[8.0]
  def change
    change_column_null :beneficiary_addresses, :iso_region_code, false
    add_column :beneficiary_addresses, :iso_country_code, :citext, null: false

    remove_index :beneficiary_addresses, [ :iso_region_code, :administrative_division_level_2_code, :administrative_division_level_3_code, :administrative_division_level_4_code ]
    remove_index :beneficiary_addresses, [ :iso_region_code, :administrative_division_level_2_name, :administrative_division_level_3_name, :administrative_division_level_4_name ]

    add_index :beneficiary_addresses, [ :iso_country_code, :iso_region_code, :administrative_division_level_2_code, :administrative_division_level_3_code, :administrative_division_level_4_code ]
    add_index :beneficiary_addresses, [ :iso_country_code, :iso_region_code, :administrative_division_level_2_name, :administrative_division_level_3_name, :administrative_division_level_4_name ]
  end
end

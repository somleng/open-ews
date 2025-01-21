class RemoveIsoCountryCodeFromBeneficiaryAddresses < ActiveRecord::Migration[8.0]
  def change
    remove_column :beneficiary_addresses, :iso_country_code, :citext
  end
end

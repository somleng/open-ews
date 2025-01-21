class ChangeIsoCountryCodeNotNullOnBeneficiaries < ActiveRecord::Migration[8.0]
  def change
    change_column_null :contacts, :iso_country_code, false
  end
end

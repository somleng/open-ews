class Update < ActiveRecord::Migration[8.0]
  def change
    change_column_null :beneficiary_addresses, :iso_region_code, false
  end
end

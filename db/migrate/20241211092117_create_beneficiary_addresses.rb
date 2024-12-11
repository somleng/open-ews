class CreateBeneficiaryAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :beneficiary_addresses do |t|
      t.references :account, null: false, foreign_key: true
      t.references :beneficiary, null: false, foreign_key: { to_table: :contacts, on_delete: :cascade }
      t.citext :iso_region_code
      t.string :administrative_division_level_2_code
      t.string :administrative_division_level_2_name
      t.string :administrative_division_level_3_code
      t.string :administrative_division_level_3_name
      t.string :administrative_division_level_4_code
      t.string :administrative_division_level_4_name

      t.timestamps

      t.index [ :account_id, :iso_region_code, :administrative_division_level_2_code, :administrative_division_level_3_code, :administrative_division_level_4_code ]
      t.index [ :account_id, :iso_region_code, :administrative_division_level_2_name, :administrative_division_level_3_name, :administrative_division_level_4_name ]
    end
  end
end

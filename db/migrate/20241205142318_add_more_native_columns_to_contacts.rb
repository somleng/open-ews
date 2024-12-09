class AddMoreNativeColumnsToContacts < ActiveRecord::Migration[8.0]
  def change
    change_table :contacts do |t|
      t.string :status, null: false, default: 'active'
      t.string :language_code
      t.string :gender
      t.date :date_of_birth

      t.string :iso_country_code
      t.string :iso_region_code
      t.string :administrative_division_level_2_code
      t.string :administrative_division_level_2_name
      t.string :administrative_division_level_3_code
      t.string :administrative_division_level_3_name
      t.string :administrative_division_level_4_code
      t.string :administrative_division_level_4_name

      t.index [ :account_id, :status ], where: "status='active'"
      t.index [ :account_id, :language_code ]
      t.index [ :account_id, :gender ]
      t.index [ :account_id, :date_of_birth ]
      t.index [ :account_id, :iso_country_code, :iso_region_code, :administrative_division_level_2_code, :administrative_division_level_3_code, :administrative_division_level_4_code ]
      t.index [ :account_id, :iso_country_code, :iso_region_code, :administrative_division_level_2_name, :administrative_division_level_3_name, :administrative_division_level_4_name ]
    end
  end
end

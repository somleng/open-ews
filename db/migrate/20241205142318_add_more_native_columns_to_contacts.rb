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

      t.index :metadata, using: :gin
    end
  end
end

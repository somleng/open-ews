class AddMoreNativeColumnsToContacts < ActiveRecord::Migration[8.0]
  def change
    change_table :contacts do |t|
      t.string :status, null: false, default: 'active'
      t.string :language_code
      t.string :gender
      t.date :date_of_birth
      t.citext :iso_country_code

      t.index [ :account_id, :status ], where: "status='active'"
      t.index [ :account_id, :language_code ]
      t.index [ :account_id, :gender ]
      t.index [ :account_id, :date_of_birth ]
      t.index [ :account_id, :iso_country_code ]
    end
  end
end

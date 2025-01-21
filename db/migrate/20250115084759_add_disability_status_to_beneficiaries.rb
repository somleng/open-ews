class AddDisabilityStatusToBeneficiaries < ActiveRecord::Migration[8.0]
  def change
    add_column :contacts, :disability_status, :string

    add_index :contacts, [ :account_id, :disability_status ]
  end
end

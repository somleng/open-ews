class RenameContactToBeneficiary < ActiveRecord::Migration[8.0]
  def change
    rename_table :contacts, :beneficiaries

    rename_column :callout_participations, :contact_id, :beneficiary_id
    rename_column :phone_calls, :contact_id, :beneficiary_id
    rename_column :recordings, :contact_id, :beneficiary_id
  end
end

class AddBeneficiaryPhoneNumberToCalloutParticipations < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      UPDATE contacts
      SET msisdn = REPLACE(msisdn, '+', '')
      WHERE msisdn LIKE '+%';

      UPDATE phone_calls
      SET msisdn = REPLACE(msisdn, '+', '')
      WHERE msisdn LIKE '+%';
    SQL

    add_column :callout_participations, :beneficiary_phone_number, :string
    execute <<-SQL
      UPDATE callout_participations cp
      SET beneficiary_phone_number = c.msisdn
      FROM contacts c
      WHERE cp.contact_id = c.id
    SQL
    change_column_null :callout_participations, :beneficiary_phone_number, false

    remove_foreign_key :callout_participations, :contacts
    add_foreign_key :callout_participations, :contacts, on_delete: :nullify
    change_column_null :callout_participations, :contact_id, true

    remove_foreign_key :phone_calls, :contacts
    add_foreign_key :phone_calls, :contacts, on_delete: :nullify
    change_column_null :phone_calls, :contact_id, true
  end

  def down
    remove_column :callout_participations, :beneficiary_phone_number
    change_column_null :callout_participations, :contact_id, false
    change_column_null :phone_calls, :contact_id, false
  end
end

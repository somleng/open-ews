class AddBeneficiaryPhoneNumberToCalloutParticipations < ActiveRecord::Migration[8.0]
  def up
    say_with_time "Migrating on contacts" do
      execute <<-SQL
        UPDATE contacts
        SET msisdn = REPLACE(msisdn, '+', '')
        WHERE msisdn LIKE '+%';
      SQL
    end

    # Allow null for now to migrate existing data
    add_column :callout_participations, :beneficiary_phone_number, :string, null: true

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

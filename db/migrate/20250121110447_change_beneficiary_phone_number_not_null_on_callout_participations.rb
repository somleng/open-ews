class ChangeBeneficiaryPhoneNumberNotNullOnCalloutParticipations < ActiveRecord::Migration[8.0]
  def change
    change_column_null :callout_participations, :beneficiary_phone_number, false
  end
end

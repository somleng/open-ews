class RenameMsisdnToPhoneNumber < ActiveRecord::Migration[8.0]
  def change
    rename_column :contacts, :msisdn, :phone_number
    rename_column :phone_calls, :msisdn, :phone_number
    rename_column :callout_participations, :beneficiary_phone_number, :phone_number

    remove_column :callout_participations, :msisdn, :string
  end
end

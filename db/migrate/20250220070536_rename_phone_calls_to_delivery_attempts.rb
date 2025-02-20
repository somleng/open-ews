class RenamePhoneCallsToDeliveryAttempts < ActiveRecord::Migration[8.0]
  def change
    rename_table :phone_calls, :delivery_attempts
    rename_column :recordings, :phone_call_id, :delivery_attempt_id
    rename_column :remote_phone_call_events, :phone_call_id, :delivery_attempt_id
    rename_column :alerts, :phone_calls_count, :delivery_attempts_count
  end
end

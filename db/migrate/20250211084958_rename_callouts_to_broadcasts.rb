class RenameCalloutsToBroadcasts < ActiveRecord::Migration[8.0]
  def change
    rename_table :callouts, :broadcasts

    rename_column :phone_calls, :callout_id, :broadcast_id
    rename_column :batch_operations, :callout_id, :broadcast_id
    rename_column :callout_participations, :callout_id, :broadcast_id
  end
end

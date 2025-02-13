class RenameCalloutParticipationsToAlerts < ActiveRecord::Migration[8.0]
  def change
    rename_table :callout_participations, :alerts
    rename_column :phone_calls, :callout_participation_id, :alert_id
  end
end

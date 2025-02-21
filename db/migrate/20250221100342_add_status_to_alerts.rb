class AddStatusToAlerts < ActiveRecord::Migration[8.0]
  def change
    add_column :alerts, :status, :string

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE alerts
          SET status = CASE
              WHEN answered = true THEN 'completed'
              WHEN answered = false AND delivery_attempts_count >= 3 THEN 'failed'
              ELSE 'queued'
          END
        SQL
      end
    end

    change_column_null :alerts, :status, false
    remove_column :alerts, :answered, :boolean, default: false
  end
end

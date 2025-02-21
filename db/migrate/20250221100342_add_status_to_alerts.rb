class AddStatusToAlerts < ActiveRecord::Migration[8.0]
  def change
    add_column :alerts, :status, :string

    reversible do |dir|
      dir.up do
        Alert.where(answered: true).update_all(status: "completed")
        Alert.where(answered: false).update_all(status: "failed")
      end
    end

    change_column_null :alerts, :status, false
    remove_column :alerts, :answered, :boolean, default: false
  end
end

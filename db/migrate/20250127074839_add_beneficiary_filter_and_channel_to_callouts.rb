class AddBeneficiaryFilterAndChannelToCallouts < ActiveRecord::Migration[8.0]
  def change
    add_column :callouts, :channel, :string
    add_column :callouts, :beneficiary_filter, :jsonb, null: false, default: {}

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE callouts SET channel = 'voice';
          UPDATE callouts SET status = 'stopped' WHERE status = 'paused';
          UPDATE callouts SET status = 'pending' WHERE status = 'initialized';
        SQL
      end
    end

    change_column_null(:callouts, :channel, false)
  end
end

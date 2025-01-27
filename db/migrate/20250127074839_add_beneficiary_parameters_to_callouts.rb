class AddBeneficiaryParametersToCallouts < ActiveRecord::Migration[8.0]
  def change
    add_column :callouts, :beneficiary_parameters, :jsonb, null: false, default: {}
  end
end

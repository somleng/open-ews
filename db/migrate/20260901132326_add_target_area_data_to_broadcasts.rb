class AddTargetAreaDataToBroadcasts < ActiveRecord::Migration[8.1]
  def change
    add_column(:broadcasts, :target_area_data, :jsonb, null: false, default: {})
  end
end

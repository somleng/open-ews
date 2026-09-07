class CreateBroadcastTargetAreas < ActiveRecord::Migration[8.1]
  def change
    create_table :broadcast_target_areas do |t|
      t.references :broadcast, null: false, index: false, foreign_key: { on_delete: :cascade }
      t.string :iso_region_code, null: false
      t.string :administrative_division_level_2_code, null: true
      t.string :administrative_division_level_3_code, null: true
      t.string :administrative_division_level_4_code, null: true
      t.string :administrative_division_level_5_code, null: true

      t.index(
        [
          :broadcast_id,
          :iso_region_code,
          :administrative_division_level_2_code,
          :administrative_division_level_3_code,
          :administrative_division_level_4_code,
          :administrative_division_level_5_code
        ],
        unique: true
      )

      t.timestamps
    end
  end
end

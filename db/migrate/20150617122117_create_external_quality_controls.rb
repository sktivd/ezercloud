class CreateExternalQualityControls < ActiveRecord::Migration
  def change
    create_table :external_quality_controls do |t|
      t.string :equipment
      t.integer :device_id
      t.integer :test_id
      t.string :sample_type
      t.string :reagent
      t.string :lot_number
      t.datetime :expired_at
      t.string :unit
      t.float :mean
      t.float :sd

      t.timestamps null: false
    end
  end
end

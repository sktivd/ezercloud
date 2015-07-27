class CreateFrends < ActiveRecord::Migration
  def change
    create_table :frends do |t|
      t.integer :version
      t.string :manufacturer
      t.string :serial_number
      t.integer :test_type
      t.boolean :processed, null: false, default: false
      t.string :error_code
      t.integer :kit
      t.integer :lot
      t.string :test_id, null: false, default: '::'
      t.string :test_result, null: false, default: '::'
      t.string :integrals
      t.string :center_points
      t.float :average_background
      t.integer :measured_points
      t.text :point_intensities
      t.string :qc_service
      t.string :qc_lot
      t.date :qc_expire
      t.boolean :internal_qc_laser_power_test
      t.boolean :internal_qc_laseralignment_test
      t.boolean :internal_qc_calcaulated_ratio_test
      t.boolean :internal_qc_test

      t.timestamps null: false
    end
  end
end

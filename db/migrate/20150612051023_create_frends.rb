class CreateFrends < ActiveRecord::Migration
  def change
    create_table :frends do |t|
      t.integer :version
      t.string :manufacturer
      t.string :serial_number
      t.integer :test_type
      t.boolean :processed, null: false, default: false
      t.string :error_code
      t.integer :device_id
      t.integer :device_lot
      t.integer :test_id0
      t.integer :test_id1
      t.integer :test_id2
      t.float :test_result0
      t.float :test_result1
      t.float :test_result2
      t.integer :test_integral0
      t.integer :test_integral1
      t.integer :test_integral2
      t.integer :control_integral
      t.integer :test_center_point0
      t.integer :test_center_point1
      t.integer :test_center_point2
      t.integer :control_center_point
      t.float :average_background
      t.integer :measured_points
      t.text :point_intensities
      t.string :qc_service
      t.string :qc_lot
      t.boolean :internal_qc_laser_power_test
      t.boolean :internal_qc_laseralignment_test
      t.boolean :internal_qc_calcaulated_ratio_test
      t.boolean :internal_qc_test

      t.timestamps null: false
    end
  end
end

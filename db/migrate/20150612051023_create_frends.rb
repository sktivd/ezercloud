class CreateFrends < ActiveRecord::Migration
  def change
    create_table :frends do |t|
      t.integer :version
      t.string :manufacturer
      t.string :serial_number
      t.integer :test_type
      t.boolean :processed
      t.string :error_code
      t.integer :device_id
      t.integer :device_ln
      t.integer :test0_id
      t.integer :test1_id
      t.integer :test2_id
      t.float :test0_result
      t.float :test1_result
      t.float :test2_result
      t.integer :test0_integral
      t.integer :test1_integral
      t.integer :test2_integral
      t.integer :control_integral
      t.integer :test0_center_point
      t.integer :test1_center_point
      t.integer :test2_center_point
      t.integer :control_center_point
      t.float :average_background
      t.integer :measured_points
      t.text :point_intensities
      t.string :external_qc_service_id
      t.string :external_qc_catalog
      t.string :external_qc_ln
      t.decimal :external_qc_level
      t.boolean :internal_qc_laser_power_test
      t.boolean :internal_qc_laseralignment_test
      t.boolean :internal_qc_calcaulated_ratio_test
      t.boolean :internal_qc_test

      t.timestamps null: false
    end
  end
end

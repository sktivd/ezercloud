class CreateBuddis < ActiveRecord::Migration
  def change
    create_table :buddis do |t|
      t.integer :version
      t.string :manufacturer
      t.string :serial_number
      t.boolean :processed
      t.string :error_code
      t.string :kit
      t.string :lot
      t.date :device_expired_date
      t.string :patient_id
      t.string :test_zone_data
      t.string :control_zone_data
      t.string :ratio_data

      t.timestamps null: false
    end
  end
end

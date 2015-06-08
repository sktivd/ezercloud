class CreateDiagnoses < ActiveRecord::Migration
  def change
    create_table :diagnoses do |t|
      t.string :protocol_id
      t.integer :version
      t.string :manufacturer_id
      t.string :equipment_id
      t.string :serial_number
      t.integer :year
      t.integer :month
      t.integer :day
      t.integer :hour
      t.integer :minute
      t.integer :second
      t.string :time_zone
      t.decimal :elapsed_time
      t.string :ip_address
      t.float :latitude
      t.float :longitude
      t.text :data

      t.timestamps null: false
    end
  end
end

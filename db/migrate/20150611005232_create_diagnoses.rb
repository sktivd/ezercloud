class CreateDiagnoses < ActiveRecord::Migration
  def change
    create_table :diagnoses do |t|
      t.string :protocol
      t.integer :version
      t.string :equipment
      t.datetime :measured_at
      t.float :elapsed_time
      t.string :ip_address
      t.string :location
      t.float :latitude
      t.float :longitude
      t.string :location
      t.string :technician
      t.integer :sex, default: -1
      t.integer :age_band, default: -1
      t.string :order_number
      t.references :diagnosable, polymorphic: true, index: true
      
      t.timestamps null: false
    end
  end
end

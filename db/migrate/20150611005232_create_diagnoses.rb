class CreateDiagnoses < ActiveRecord::Migration
  def change
    create_table :diagnoses do |t|
      t.string :protocol
      t.integer :version
      t.string :authorized_key
      t.string :equipment
      t.string :measured_at
      t.float :elapsed_time
      t.string :ip_address
      t.float :latitude
      t.float :longitude
      t.text :data

      t.timestamps null: false
    end
  end
end

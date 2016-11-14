class CreateDeviceLicenses < ActiveRecord::Migration
  def change
    create_table :device_licenses do |t|
      t.datetime   :activated_at, null: false
      t.datetime   :deactivated_at
      t.references :account, index: true, foreign_key: true
      t.references :device,  index: true, foreign_key: true
      
      t.timestamps null: false
    end
  end
end

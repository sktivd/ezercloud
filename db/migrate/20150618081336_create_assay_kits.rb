class CreateAssayKits < ActiveRecord::Migration
  def change
    create_table :assay_kits do |t|
      t.string :equipment
      t.string :manufacturer
      t.integer :device_id
      t.integer :number_of_tests
      t.string :reagents,         array: true, default: [""]
      t.integer :references,      array: true, default: [0]

      t.timestamps null: false
    end
  end
end

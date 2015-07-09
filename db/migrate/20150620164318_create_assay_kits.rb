class CreateAssayKits < ActiveRecord::Migration
  def change
    create_table :assay_kits do |t|
      t.string :equipment
      t.string :manufacturer
      t.string :device
      t.integer :kit

      t.timestamps null: false
    end
  end
end

class CreateAssayKits < ActiveRecord::Migration
  def change
    create_table :assay_kits do |t|
      t.string :equipment
      t.string :manufacturer
      t.integer :kit_id

      t.timestamps null: false
    end
  end
end

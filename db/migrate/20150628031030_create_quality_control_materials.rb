class CreateQualityControlMaterials < ActiveRecord::Migration
  def change
    create_table :quality_control_materials do |t|
      t.string :service
      t.string :lot_number
      t.date :expire
      t.string :equipment
      t.string :manufacturer
      t.string :reagent_name
      t.integer :reagent_number
      t.string :unit
      t.float :mean
      t.float :sd
      t.belongs_to :reagent, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

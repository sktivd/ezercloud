class CreateEquipment < ActiveRecord::Migration
  def change
    create_table :equipment do |t|
      t.string :equipment
      t.string :manufacturer
      t.string :klass

      t.timestamps null: false
    end
  end
end

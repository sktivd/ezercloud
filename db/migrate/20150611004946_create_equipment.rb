class CreateEquipment < ActiveRecord::Migration
  def change
    create_table :equipment do |t|
      t.string :equipment
      t.string :manufacturer
      t.string :klass
      t.string :db
      t.integer :tests
      t.string :prefix
      
      t.timestamps null: false
    end
  end
end

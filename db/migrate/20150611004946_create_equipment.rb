class CreateEquipment < ActiveRecord::Migration
  def change
    create_table :equipment do |t|
      t.string :equipment
      t.string :manufacturer
      t.string :klass
      t.string :db
      t.string :variable_kit
      t.text   :variables_test_ids
      t.text   :variables_test_values
      t.string :variable_qc_service
      t.string :variable_qc_lotnumber      

      t.timestamps null: false
    end
  end
end

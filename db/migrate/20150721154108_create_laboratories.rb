class CreateLaboratories < ActiveRecord::Migration
  def change
    create_table :laboratories do |t|
      t.string :ip_address
      t.string :equipment
      t.integer :kit

      t.timestamps null: false
    end
  end
end

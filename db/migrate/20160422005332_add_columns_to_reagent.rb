class AddColumnsToReagent < ActiveRecord::Migration
  def change
    change_table :reagents do |t|
      t.column :equipment, :string
      t.column :lod,       :float
      t.column :uod,       :float
      t.column :threshold, :float
    end
    
    reversible do |dir|
      dir.up do
        Reagent.all.each do |reagent|
          reagent.equipment = 'FREND' if reagent.equipment.nil?
          reagent.save
        end    
      end
      dir.down do
      end
    end
  end
end

class AddMappableToEquipment < ActiveRecord::Migration
  def change
    add_column :equipment, :mappable, :boolean, default: false
    reversible do |dir|
      dir.up do
        Equipment.where(equipment: ['EzerReader', 'BUDDI']).each do |equipment|
          equipment.update_attributes(mappable: true)
        end
      end
      dir.down do
      end
    end
  end
end

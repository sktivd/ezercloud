class AddAssayKitReagentNumbersToPlate < ActiveRecord::Migration
  def change
    add_column :plates, :kit, :integer
    add_column :plates, :number, :integer
    
    reversible do |dir|
      dir.up do
        Plate.all.each do |plate|
          plate.kit = plate.assay_kit.kit
          plate.number = plate.reagent.number
          plate.save
        end
      end
      dir.down do
      end
    end
  end
end

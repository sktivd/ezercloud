class ReagentMigrateToManyToMany < ActiveRecord::Migration
  def up
    change_table :quality_control_materials do |t|
      t.belongs_to :plate, index: true, foreign: true
    end
    
    change_table :reports do |t|
      t.belongs_to :plate, index: true, foreign: true
    end
    
    Reagent.all.each do |reagent|
      plate = reagent.plates.create(assay_kit: AssayKit.find(reagent.assay_kit_id))
      QualityControlMaterial.where(reagent_id: reagent.id).each do |quality_control_material|
        quality_control_material.plate = plate
        quality_control_material.save!
      end
      Report.where(reagent_id: reagent.id).each do |report|
        report.plate = plate
        report.save!
      end
    end
    
    change_table :reagents do |t|
      t.remove_belongs_to :assay_kit
    end

    change_table :reports do |t|
      t.remove_belongs_to :reagent
    end
    
    change_table :quality_control_materials do |t|
      t.remove_belongs_to :reagent
    end
  end
  
  # Before Roll Back
  ###
  ### reagent.rb:
  ###  validates :equipment, :number, presence: true            (should removed)
  ###  validates :number, uniqueness: { scope: [:equipment] }   (should removed)
  def down
    change_table :quality_control_materials do |t|
      t.belongs_to :reagent, index: true, foreign: true
    end

    change_table :reports do |t|
      t.belongs_to :reagent, index: true, foreign: true
    end

    change_table :reagents do |t|
      t.belongs_to :assay_kit, index: true, foreign_key: true
    end
        
    Plate.all.each do |plate|
      plate.reagent.assay_kit_id = plate.assay_kit_id
      plate.reagent.save!
      plate.reports.each do |report|
        report.reagent_id = plate.reagent_id
        report.save!
      end
      plate.quality_control_materials.each do |quality_control_material|
        quality_control_material.reagent_id = plate.reagent_id
        quality_control_material.save!
      end
    end

    change_table :reports do |t|
      t.remove_belongs_to :plate
    end    
    
    change_table :quality_control_materials do |t|
      t.remove_belongs_to :plate
    end    
  end
end

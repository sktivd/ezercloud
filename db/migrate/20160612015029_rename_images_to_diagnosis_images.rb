#
# migrate
#   Before migration, app/models/image.rb should exist and its class name should be 'Image'.
#   After migration, app/models/image.rb should be renamed by 'diagnosis_image.rb' and 
#     its class name should be enamed by 'DiagnosisImage'.
#
# rollback
#   Before rollback, app/models/diagnosis_image.rb should exist and its class name should be 'DiagnosisImage'.
#   After rollback, app/models/diagnosis_image.rb should be renamed by 'image.rb' and its 
#     class name should be renamed by 'Image'.
#

class RenameImagesToDiagnosisImages < ActiveRecord::Migration    
  def change
    add_reference :images, :diagnosis_imagable, polymorphic: true, index: { name: 'd_imagable' }
    reversible do |dir|
      Image.all.each do |image|
        dir.up do
          image.diagnosis_imagable_id   = image.imagable_id
          image.diagnosis_imagable_type = image.imagable_type
        end
        dir.down do
          image.imagable_id   = image.diagnosis_imagable_id
          image.imagable_type = image.diagnosis_imagable_type
        end
      end
    end
    remove_reference :images, :imagable, polymorphic: true, index: true
    rename_table :images, :diagnosis_images
  end
end

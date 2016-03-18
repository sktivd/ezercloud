class AddPointIntensityToEzerReader < ActiveRecord::Migration
  def change
    add_column :diagnoses, :measured_points, :integer
    add_column :diagnoses, :point_intensities, :text
  end
end

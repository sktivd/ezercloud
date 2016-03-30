class AddPointIntensityToEzerReader < ActiveRecord::Migration
  def change
    add_column :ezer_readers, :measured_points, :integer
    add_column :ezer_readers, :point_intensities, :text
  end
end

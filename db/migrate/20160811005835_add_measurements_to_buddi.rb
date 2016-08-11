class AddMeasurementsToBuddi < ActiveRecord::Migration
  def change
    add_column :buddis, :measured_points,   :string
    add_column :buddis, :point_intensities, :text
  end
end

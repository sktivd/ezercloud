class AddAColumnToAssayKits < ActiveRecord::Migration
  def change
    add_column :assay_kits, :device, :string
  end
end

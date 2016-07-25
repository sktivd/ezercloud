class AddTargetToAssay < ActiveRecord::Migration
  def change
    add_column :assay_kits, :target, :string, default: 'NA'
    reversible do |dir|
      dir.up do
        AssayKit.all.each { |assay_kit| assay_kit.update_attributes(target: assay_kit.device) }
      end
      dir.down {}
    end
  end
end

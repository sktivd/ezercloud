class AddColumnToAssayKit < ActiveRecord::Migration
  def change
    add_column :assay_kits, :diagnosis_ruleset, :string
  end
end

class ChangeColumnTypeOnDiagnoses < ActiveRecord::Migration
  def up
    change_column :diagnoses, :measured_at, :datetime
  end
  def down
    change_column :diagnoses, :measured_at, :string
  end
end

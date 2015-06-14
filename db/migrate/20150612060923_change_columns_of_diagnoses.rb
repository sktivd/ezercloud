class ChangeColumnsOfDiagnoses < ActiveRecord::Migration
  def up
    remove_column :diagnoses, :data
    add_column    :diagnoses, :sex,           :integer, default: -1
    add_column    :diagnoses, :age_band,      :integer, default: -1
    add_column    :diagnoses, :order_number,  :string
  end
  
  def down
    add_column     :diagnoses, :data,         :text
    remove_column  :diagnoses, :sex
    remove_column  :diagnoses, :age_band
    remove_column  :diagnoses, :order_number
  end
end

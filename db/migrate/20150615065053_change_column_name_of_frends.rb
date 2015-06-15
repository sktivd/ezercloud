class ChangeColumnNameOfFrends < ActiveRecord::Migration
  def change
    rename_column :frends, :type, :test_type
  end
end

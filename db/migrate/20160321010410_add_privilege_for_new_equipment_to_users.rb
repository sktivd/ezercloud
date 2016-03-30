class AddPrivilegeForNewEquipmentToUsers < ActiveRecord::Migration
  def change
    add_column :users, :equipment_buddis, :boolean, default: false
    add_column :users, :equipment_ezer_readers, :boolean, default: false
    add_column :users, :privilege_monitoring, :boolean, default: false
    add_column :users, :privilege_qc, :boolean, default: false
    add_column :users, :authorized, :boolean, default: false
  end
end

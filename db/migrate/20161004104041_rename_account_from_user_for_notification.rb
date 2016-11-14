class RenameAccountFromUserForNotification < ActiveRecord::Migration
  def up
    remove_reference :notifications, :user if Notification.column_names.include?('user_id')
    add_reference :notifications, :account, index: true, foreign_key: true
  end
  
  def down
    remove_reference :notifications, :account
  end
end

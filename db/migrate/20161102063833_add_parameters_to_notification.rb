class AddParametersToNotification < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :query, :text
  end
end

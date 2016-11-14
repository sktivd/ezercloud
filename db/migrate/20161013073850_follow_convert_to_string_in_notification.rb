class FollowConvertToStringInNotification < ActiveRecord::Migration
  def self.up
    change_column :notifications, :follow, :string, default: 'notice', null: false
    Notification.all.each do |notification|
      follow = case notification.follow
      when '0'
        notification.update_attributes(follow: 'notice')
      when '1'
        notification.update_attributes(follow: 'response')
      when '99'
        notification.update_attributes(follow: 'undefined')
      end
    end    
  end
  
  def self.down
    Notification.all.each do |notification|
      follow = case notification.follow
      when 'notice'
        notification.update_attributes(follow: '0')
      when 'response'
        notification.update_attributes(follow: '1')
      when 'undefined'
        notification.update_attributes(follow: '99')
      end
    end
    connection.execute(%q{
      alter table notifications
      alter column follow
      type integer using cast (follow as integer)
    })
    change_column :notifications, :follow, :integer, default: 0, null: false
  end
end

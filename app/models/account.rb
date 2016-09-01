class Account < ActiveRecord::Base
  rolify
  include Authority::UserAbilities
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # :registerable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable, :timeoutable, :invitable, timeout_in: 30.minutes, invite_for: 2.weeks
  
  attr_accessor :area_fields
  
  def areas
    cover_area.split('|')
  end
  
end

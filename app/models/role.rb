class Role < ActiveRecord::Base
  has_and_belongs_to_many :accounts, :join_table => :accounts_roles

  belongs_to :resource,
             :polymorphic => true
             
  attr_accessor :tag, :role, :field, :note

  validates :resource_type,
            :inclusion => { :in => Rolify.resource_types },
            :allow_nil => true

  scopify
end

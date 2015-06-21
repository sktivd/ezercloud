class AssayKit < ActiveRecord::Base
  has_many :reagents, dependent: :destroy
  accepts_nested_attributes_for :reagents, reject_if: lambda { |e| e[:name].blank? or e[:number].to_i <= 0 }, allow_destroy: true
end

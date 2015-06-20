class AssayKit < ActiveRecord::Base
  has_many :reagents, dependent: :destroy
  accepts_nested_attributes_for :reagents, reject_if: lambda { |e| e[:content].blank? }, allow_destroy: true
end

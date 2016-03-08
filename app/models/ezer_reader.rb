class EzerReader < ActiveRecord::Base
  include NotificationUtils
  has_one  :diagnosis, as: :diagnosable, dependent: :delete
  has_many :images,    as: :imagable,    dependent: :delete_all

  VERSION = 1

  validates :serial_number, :kit, :lot, presence: true
  validates :version,       numericality: { equal_to: VERSION, message: "should be matched to server's version" }  

  def self.read
    self.order(:created_at).reverse_order.includes(:diagnosis)
  end

end
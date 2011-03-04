class LiquorLicense < ActiveRecord::Base

  validates :title, :presence => true
  validates :purpose, :presence => { :message => "should be chosen" }
  validates_numericality_of :price, :only_integer => false, :message => "can only be float"
  validate :expiration_date_cannot_be_in_the_past
  def expiration_date_cannot_be_in_the_past
    errors.add(:expiration_date, "can't be in the past") if
    (expiration_date != nil and expiration_date < Date.today())
  end
  belongs_to :user , :class_name => 'User'
  belongs_to :buyer , :class_name => 'User'
  has_many :liquor_license_auctions
end

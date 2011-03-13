class LiquorLicenseAuction < ActiveRecord::Base
  validates_numericality_of :price, :only_integer => false, :message => "can only be float"
  belongs_to :liquor_license
  belongs_to :user , :class_name => 'User'
  belongs_to :bidder , :class_name => 'User'
  has_many :bid_activity
end

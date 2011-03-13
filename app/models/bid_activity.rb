class BidActivity < ActiveRecord::Base
  belongs_to :user
  belongs_to :liquor_license_auction
end

class UserDetail < ActiveRecord::Base
  validates :real_name, :street_address, :state, :city, :post_code, :paypal_account ,:presence => true
  validates_format_of :paypal_account, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "must be a valid email"
  validates_numericality_of :post_code, :only_integer => true, :message => "can only be integer"
  belongs_to :use
end

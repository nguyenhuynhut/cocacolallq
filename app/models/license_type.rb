class LicenseType < ActiveRecord::Base
  validates :license_code , :description ,:presence => true
  validates_uniqueness_of :license_code
  has_many :liquor_licenses
  has_many :criterias
end

class Criteria < ActiveRecord::Base
  validates :state_id, :city_id , :presence => true
  belongs_to :user
  belongs_to :license_type
end

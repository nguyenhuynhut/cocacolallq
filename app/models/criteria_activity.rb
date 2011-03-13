class CriteriaActivity < ActiveRecord::Base
  belongs_to :user
  belongs_to :liquor_license
end

class User < ActiveRecord::Base

  validates :username , :kind ,:presence => true
  validates_uniqueness_of :email
  validates_uniqueness_of :username
  validates_length_of :username, :within => 5..50
  validates_length_of :password, :within => 5..50
  validates_confirmation_of :password 
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "must be valid"
  before_save :hash_password
  def hash_password
    if password_changed?
      self.password = Digest::SHA1.hexdigest(password)
    end
  end
  has_many :liquor_licenses ,:dependent => :destroy
  has_one :user_detail, :dependent=> :destroy
end

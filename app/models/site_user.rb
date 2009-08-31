# == Schema Information
# Schema version: 20090823223617
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  email                     :string(255)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(255)
#  remember_token_expires_at :datetime
#  email_verification_code   :string(40)
#  email_verified_at         :datetime
#  state                     :string(255)     default("passive")
#  deleted_at                :datetime
#  name                      :string(255)
#  identity_url              :string(255)
#  type                      :string(255)
#

class SiteUser < User

  # Validations:
  validates_presence_of     :email
  validates_presence_of     :password, :password_confirmation, :if => :password_required?
  validates_length_of       :password, :within => 3..40, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?

  before_save :encrypt_password, :if => :password_required?

  # Event Declarations:
  event :activate do
    transitions :from => :passive, :to => :active, :guard => Proc.new {|u| u.valid? && !(u.crypted_password.blank? && u.password.blank?) }
  end

  # Accessible Attributes: 
  attr_accessible :email, :name, :password, :password_confirmation

  # Only authenticates SiteUsers...
  def self.authenticate(email, password)
    u = SiteUser.find_by_email(email)
    u && u.authenticated?(password) ? u : nil
  end

  def authenticated?(password)
    (verified? || active?) && (crypted_password == encrypt(password))
  end

  protected

  def password_required?
    (new_record? || (!password_confirmation.blank? || !password.blank?))
  end

  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
    self.crypted_password = encrypt(password)
  end

end

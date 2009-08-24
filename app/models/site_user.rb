
class SiteUser < User

  # Validations:
  validates_presence_of     :password, :password_confirmation, :email
  validates_length_of       :password, :within => 3..40
  validates_confirmation_of :password

  before_save :encrypt_password

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

  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
    self.crypted_password = encrypt(password)
  end

end

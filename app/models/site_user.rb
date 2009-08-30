
class SiteUser < User
  # Virtual attribute for the password
  attr_accessor :password, :password_confirmation

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


class SiteUser < User

  # Virtual attribute for the password
  attr_accessor :password

  # Validations:
  validates_presence_of     :password, :password_confirmation
  validates_length_of       :password, :within => 3..40
  validates_confirmation_of :password
  validates_presence_of     :email

  before_save :encrypt_password

  # State Declarations:
  state :active
  
  attr_accessible :email, :name, :password, :password_confirmation

  # Event Declarations:
  event :register do
    transitions :from => :passive, :to => :active, :guard => Proc.new {|u| u.valid? && !(u.crypted_password.blank? && u.password.blank?) }
  end

  def self.authenticate(email, password)
    u = find :first, :conditions => ['email = ?', email] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  protected

  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
    self.crypted_password = encrypt(password)
  end

end

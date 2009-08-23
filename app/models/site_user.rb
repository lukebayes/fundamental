
require 'digest/sha1'
class SiteUser < User

  # Virtual attribute for the password
  attr_accessor :password

  # Validations:
  validates_presence_of     :password, :password_confirmation
  validates_length_of       :password, :within => 3..40
  validates_confirmation_of :password
  validates_presence_of     :email
  validates_length_of       :email, :within => 3..254
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_format_of       :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  before_save :encrypt_password

  # State Declarations:
  state :pending, :enter => :make_activation_code
  state :active,  :enter => :do_activate
  
  attr_accessible :email, :name, :password, :password_confirmation

  # Event Declarations:
  event :register do
    transitions :from => :passive, :to => :pending, :guard => Proc.new {|u| u.valid? && !(u.crypted_password.blank? && u.password.blank?) }
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

  def make_activation_code
    self.deleted_at = nil
    self.email_activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def do_activate_email
    @activated = true
    self.email_activated_at = Time.now.utc
    self.deleted_at = self.email_activation_code = nil
  end

end

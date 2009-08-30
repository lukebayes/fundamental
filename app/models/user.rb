# == Schema Information
# Schema version: 20090810050607
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  login                     :string(255)
#  email                     :string(255)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(255)
#  remember_token_expires_at :datetime
#  activation_code           :string(40)
#  activated_at              :datetime
#  state                     :string(255)     default("passive")
#  deleted_at                :datetime
#  name                      :string(255)
#  identity_url              :string(255)
#

class User < ActiveRecord::Base
  DEFAULT_LABEL = 'Anonymous'

  # Make new method into a User Factory:
  def self.new(options=nil)
    options ||= {}
    object = OpenIdUser.allocate unless options[:identity_url].blank?
    object ||= SiteUser.allocate
    object.send :initialize, options
    object
  end

  # Concrete classes will decide when to validate_presence_of :email
  validates_length_of       :email, :within => 3..254
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_format_of       :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  
  before_save :create_email_verification_code, :if => :email_changed?

  # State Machine Configuration:
  acts_as_state_machine :initial => :passive

  state :passive
  state :active
  state :verified, :enter => :on_verified
  state :suspended
  state :deleted, :enter => :on_deleted

  event :verify_email do
    transitions :from => [:passive, :active], :to => :verified, :guard => Proc.new { |u| !u.email.blank? }
  end

  event :suspend do
    transitions :from => [:passive, :active, :verified], :to => :suspended
  end

  # Public Methods:
  def recently_verified?
    @recently_verified ||= false
  end

  def label
    return name.split(' ').shift if !name.blank?
    return email.split('@').shift if !email.blank?
    return DEFAULT_LABEL
  end

  def using_open_id?
    false
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  protected

  def on_verified
    @recently_verified = true
    self.email_verified_at = Time.now.utc
    self.deleted_at = self.email_verification_code = nil
    self
  end
  
  # Encrypts some data with the salt.
  def encrypt(password, salt=nil)
    salt ||= self.salt
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def create_email_verification_code
    self.deleted_at = self.email_verified_at = nil
    self.email_verification_code = ActiveSupport::SecureRandom.hex(6)
  end

  def on_deleted
    self.deleted_at = Time.now.utc
  end

  #event :delete do
  #  transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
  #end
  #
  #event :unsuspend do
  #  transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| !u.activated_at.blank? }
  #  transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| !u.activation_code.blank? }
  #  transitions :from => :suspended, :to => :passive
  #end
  #
  
  #validates_uniqueness_of   :identity_url, :if => :using_open_id?
  #
  #
  ## prevents a user from submitting a crafted form that bypasses activation
  ## anything else you want your user to change should be added here.
  #attr_accessible :login, :email, :name, :password, :password_confirmation, :identity_url
  #
  #acts_as_state_machine :initial => :pending
  #state :passive
  #state :pending, :enter => :make_activation_code
  #state :active,  :enter => :do_activate
  #state :suspended
  #state :deleted, :enter => :do_delete
  #
  #
  #event :activate do
  #  transitions :from => :pending, :to => :active
  #end
  #
  ## Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  #
  #def label
  #  name || login
  #end
  #
  #def using_openid?
  #  false
  #end
  #
  ## Encrypts the password with the user salt
  #def encrypt(password)
  #  self.class.encrypt(password, salt)
  #end
  #
  #
  #def remember_token?
  #  remember_token_expires_at && Time.now.utc < remember_token_expires_at
  #end
  #
  #def using_open_id?
  #  !identity_url.blank?
  #end
  #
  #protected
  #
  #
  #def creating_with_open_id?
  #  using_open_id? && new_record?
  #end
  #
end

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

  # Make new method into a User Factory:
  def self.new(options=nil)
    options ||= {}
    object = SiteUser.allocate if(options[:identity_url].blank?)
    
    object.send :initialize, options
    object
  end

  validates_length_of       :email, :within => 3..254
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_format_of       :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  
  acts_as_state_machine :initial => :passive

  state :passive

  before_save :create_email_activation_code, :if => :email_changed?

  def recently_verified_email?
    @email_verified ||= false
  end

  def verify_email!
    verify_email.save!
  end

  def verify_email
    @email_verified = true
    self.email_activated_at = Time.now.utc
    self.deleted_at = self.email_activation_code = nil
    self
  end

  def label
    name || email
  end

  protected
  
  # Encrypts some data with the salt.
  def encrypt(password, salt=nil)
    salt ||= self.salt
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def create_email_activation_code
    self.deleted_at = nil
    self.email_activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end



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
  #event :suspend do
  #  transitions :from => [:passive, :pending, :active], :to => :suspended
  #end
  #
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
  ## These create and unset the fields required for remembering users between browser closes
  #def remember_me
  #  remember_me_for 2.weeks
  #end
  #
  #def remember_me_for(time)
  #  remember_me_until time.from_now.utc
  #end
  #
  #def remember_me_until(time)
  #  self.remember_token_expires_at = time
  #  self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
  #  save(false)
  #end
  #
  #def forget_me
  #  self.remember_token_expires_at = nil
  #  self.remember_token            = nil
  #  save(false)
  #end
  #
  #def using_open_id?
  #  !identity_url.blank?
  #end
  #
  #protected
  #
  #def password_required?
  #  !using_open_id? && (crypted_password.blank? || !password.blank?)
  #end
  #
  #def creating_with_open_id?
  #  using_open_id? && new_record?
  #end
  #
  #def do_delete
  #  self.deleted_at = Time.now.utc
  #end
  #
end

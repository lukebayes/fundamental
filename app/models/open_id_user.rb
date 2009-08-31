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


class OpenIdUser < User

  # Validations:
  validates_presence_of :identity_url
  validates_uniqueness_of :identity_url
  validates_presence_of :email, :if => :recently_activated?

  # State Declarations:
  state :active, :enter => :on_activated

  # Accessible Attributes:
  attr_accessible :identity_url, :email, :name

  # Event Declarations:
  event :activate do
    transitions :from => :passive, :to => :active, :guard => Proc.new { |u| u.valid? }
  end

  def self.authenticate(identity_url)
    OpenIdUser.find_by_identity_url(identity_url)
  end

  def using_open_id?
    true
  end

  protected

  def on_activated
    @recently_activated = true
  end

  def recently_activated?
    return @recently_activated || false
  end

end

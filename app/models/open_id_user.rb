
class OpenIdUser < User

  # Validations:
  validates_presence_of :identity_url
  validates_uniqueness_of :identity_url

  validates_presence_of :email, :if => :recently_activated?
  # State Declarations:
  state :active, :enter => :update_recently_activated

  # Accessible Attributes:
  attr_accessible :identity_url, :email, :name

  # Event Declarations:
  event :activate do
    transitions :from => :passive, :to => :active
  end

  def self.authenticate(identity_url)
    user = OpenIdUser.find_by_identity_url(:first, identity_url)
  end

  protected

  def recently_activated?
    return @recently_activated || false
  end

  def update_recently_activated
    @recently_activated = true
  end
  
end

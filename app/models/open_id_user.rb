
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
    user = OpenIdUser.find_by_identity_url(identity_url)
  end

  protected

  def on_activated
    @recently_activated = true
  end

  def recently_activated?
    return @recently_activated || false
  end

end

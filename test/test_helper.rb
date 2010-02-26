ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'shoulda'

class ActiveSupport::TestCase
  include AuthenticatedTestHelper

  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  setup do
    ActionMailer::Base.deliveries = []
  end
  
  protected
  
  def assert_validation_failure(model, field)
    assert_not_nil model.errors, "The provided model did not have any errors"
    model.errors.each do |name, message|
      return if(name == field.to_s)
    end
    fail "Expected to find validation failure for field: #{field} on model: #{model}"
  end

  def create_open_id_user(options = {})
    User.new(open_id_user_hash(options))
  end

  def open_id_user_hash(options = {})
    { :name => 'Bob Dobbs', :identity_url => 'http://openid.example.com', :email => 'bob.dobbs@example.com' }.merge(options)
  end

  def create_site_user(options = {})
    User.new(site_user_hash(options))
  end

  def site_user_hash(options = {})
    { :name => 'Quire McMan', :email => 'quire@example.com', :password => 'test', :password_confirmation => 'test' }.merge(options)
  end

  def stub_open_id_creation(identity_url, successful=true)
    result = {}
    result.expects(:successful?).returns(successful).twice
    UsersController.any_instance.expects(:authenticate_with_open_id).yields(result, identity_url)
  end

  def default_user_options(options = {})
    {
       :email => 'some.body@example.com',
       :name => 'Some Body',
       :password => 'test',
       :password_confirmation => 'test'
    }.merge(options)
  end

  def email_deliveries
    ActionMailer::Base.deliveries
  end

end

require File.dirname(__FILE__) + '/../test_helper'

class UserTestBase < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users

  protected

  def create_open_id_user(options = {})
    User.new({ :name => 'Bob Dobbs', :identity_url => 'http://openid.example.com', :email => 'bob.dobbs@example.com' }.merge(options))
  end

  def create_site_user(options = {})
    User.new({ :name => 'Quire McMan', :email => 'quire@example.com', :password => 'test', :password_confirmation => 'test' }.merge(options))
  end
end


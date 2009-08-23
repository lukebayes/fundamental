require File.dirname(__FILE__) + '/../test_helper'

class UserTestBase < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users

  protected

  def create_site_user(options = {})
    record = User.new({ :name => 'Quire McMan', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    #record.register! if record.valid?
    record
  end
end


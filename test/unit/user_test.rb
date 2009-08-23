require File.dirname(__FILE__) + '/../test_helper'
require 'user_test_base'

class UserTest < UserTestBase

  context "Creating a User instance" do

    should "be successfully created" do
      assert_difference 'User.count' do
        user = create_site_user
      end
    end

  end
end

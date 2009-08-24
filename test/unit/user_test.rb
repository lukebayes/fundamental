require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/user_test_base'

class UserTest < UserTestBase

  context "A new User" do

    setup do
      clear_deliveries
      @user = create_site_user
    end

    should "send email request for verification" do
      @user.activate!
      assert_equal 1, email_deliveries.size
    end

    should "send confirmation email" do
      @user.verify!
      @user.save!
      # One to request email verification after first creation
      # One to acknowledge email verification from verify!
      # NOT a third from second call to save!
      assert_equal 2, email_deliveries.size
    end

    context "An active User" do
      setup do
        clear_deliveries
        @user = users(:quentin)
      end

      should "not send verification email unless email is changed" do
        @user.update_attribute(:name, "Quentain")
        assert_equal 0, email_deliveries.size
      end

      should "send verification email when email is changed" do
        @user.update_attribute(:email, "123@example.com")
        assert_equal 1, email_deliveries.size
      end
    end
  end
end

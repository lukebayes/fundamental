require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/user_test_base'
require 'shoulda'

class SiteUserTest < UserTestBase

  should_validate_presence_of :password, :password_confirmation, :email
  should_not_allow_values_for :password, 'a', 'ab'
  should_allow_values_for     :password, 'abc'
  should_not_allow_values_for :email, 'a', 'abcdef', 'a@bcd', 'a@.com'

  setup do
    ActionMailer::Base.deliveries = []
  end

  context "A new SiteUser" do

    setup do
      @user = create_site_user
      @user.register!
    end

    should "have a crypted password" do
      assert_not_nil @user.crypted_password
    end

    should "be able to authenticate" do
      assert_not_nil SiteUser.authenticate(@user.email, @user.password)
    end

    should "send email activation" do
      assert_equal 1, ActionMailer::Base.deliveries.size
    end

    should "support email activation" do
      @user.verify_email!
      assert_equal 2, ActionMailer::Base.deliveries.size
    end

    context "fail authentication with" do
      should "bad email" do
        assert_nil SiteUser.authenticate('abc@def.com', @user.password)
      end

      should "bad password" do
        assert_nil SiteUser.authenticate(@user.email, 'abc')
      end
    end

  end

  context "An active SiteUser" do

    setup do
      @user = users(:quentin)
    end

    should "not send verification email unless email is changed" do
      @user.update_attribute(:name, "Quentain")
      assert_equal 0, ActionMailer::Base.deliveries.size
    end

    should "send verification email when email is changed" do
      @user.update_attribute(:email, "123@example.com")
      assert_equal 1, ActionMailer::Base.deliveries.size
    end

  end

end

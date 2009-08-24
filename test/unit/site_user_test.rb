require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/user_test_base'

class SiteUserTest < UserTestBase

  subject { SiteUser.first }

  should_validate_presence_of   :password, :password_confirmation, :email
  should_not_allow_values_for   :password, 'a', 'ab'
  should_allow_values_for       :password, 'abc'
  should_validate_uniqueness_of :email
  should_not_allow_values_for   :email, 'a', 'abcdef', 'a@bcd', 'a@.com'

  setup do
    ActionMailer::Base.deliveries = []
  end

  context "A new SiteUser" do

    setup do
      @user = create_site_user
      @user.activate!
      # TODO: Why do I have to call activate! a second time?
      @user.activate!
    end

    should "be active" do
      assert @user.active?
    end

    should "be valid" do
      assert @user.valid?
    end

    should "have a crypted password" do
      assert_not_nil @user.crypted_password
    end

    should "send email activation" do
      assert_equal 1, email_deliveries.size
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

end

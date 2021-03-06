require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  fixtures :users, :roles, :roles_users
  
  context "A new User" do

    setup do
      ActionMailer::Base.deliveries = []
      @user = create_site_user
    end

    should "send email request for verification" do
      @user.activate!
      assert_equal 1, email_deliveries.size
    end

    should "send confirmation email" do
      @user.verify_email!
      # One to request email verification after first creation
      # One to acknowledge email verification from verify_email!
      # NOT a third from second call to save!
      assert_equal 1, email_deliveries.size
    end

    should "have the web role" do
      @user.save!
      assert @user.web_role?
      assert !@user.admin_role?
    end
  end

  context "With failing email services" do
    setup do
      UserMailer.stubs(:deliver_email_verification).raises(SocketError.new('stub socket error'))
    end

    context "a new user" do

      setup do
        @user = create_site_user
      end

      should "still be activated" do
        assert_difference('User.count') do
          @user.activate!
        end
      end
    end

  end

  context "An active User" do

    setup do
      ActionMailer::Base.deliveries = []
      @user = create_site_user
      @user.activate!
      # TODO: Why do I need to call activate! twice?
      @user.activate!
    end

    should "be active" do
      assert @user.active?
    end

    should "be able to authenticate" do
      assert_not_nil SiteUser.authenticate(@user.email, 'test')
    end

    should "be suspendable" do
      @user.suspend!
      assert SiteUser.authenticate(@user.email, 'test').nil?
    end

  end

  context "A verified User" do

    setup do
      ActionMailer::Base.deliveries = []
      @user = users(:quentin)
    end

    should "be able to authenticate" do
      assert_not_nil SiteUser.authenticate(@user.email, 'test')
    end

    should "be suspendable" do
      @user.suspend!
      assert SiteUser.authenticate(@user.email, 'test').nil?
    end

    should "not send verification email unless email is changed" do
      @user.update_attribute(:name, "Quentain")
      assert_equal 0, email_deliveries.size
    end

    should "send verification email when email is changed" do
      @user.update_attribute(:email, "123@example.com")
      assert_equal 1, email_deliveries.size
    end

    should "no longer be verified after changing email" do
      @user.update_attribute(:email, "123@example.com")
      assert @user.active?, 'user is now only active'
      @user.verify_email!
      assert @user.verified?, 'verification still works'
    end

    context "label" do

      should "use first name if provided" do
        assert_equal 'Quentin', @user.label # Full name is "Quentin T"
      end

      should "fall back to email alias if no name" do
        @user.name = nil
        assert_equal 'quentin', @user.label
      end

      should "fall back to anonymous if no email or name" do
        @user.name = nil
        @user.email = nil
        assert_equal User::DEFAULT_LABEL, @user.label 
      end

    end
  end
  
  context "Checking the existence of an openid user" do
    
    context "with a nil identity_url" do
      should "return false" do
        assert_equal false, OpenIdUser.exists_for_identity_url?(nil)
      end
    end

    context "with an unknown identity_url" do
      should "return false" do
        assert_equal false, OpenIdUser.exists_for_identity_url?("abc")
      end
    end
  end
  
  context "an openid user" do
    setup { @user = users(:sean) }
    
    should "be findable by identity_url" do
      assert OpenIdUser.exists_for_identity_url?(@user.identity_url)
    end
    
  end

end

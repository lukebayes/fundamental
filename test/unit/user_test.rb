require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  fixtures :users
  
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
      @user.verify_email!
      # One to request email verification after first creation
      # One to acknowledge email verification from verify_email!
      # NOT a third from second call to save!
      assert_equal 1, email_deliveries.size
    end
  end

  context "An active User" do

    setup do
      clear_deliveries
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
      clear_deliveries
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

end

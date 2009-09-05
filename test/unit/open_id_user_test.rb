require File.dirname(__FILE__) + '/../test_helper'

class OpenIdUserTest < ActiveSupport::TestCase

  # Without this line, attempts to validate presence of identity_url
  # fail, because new users are created as SiteUsers
  subject { create_open_id_user }

  should_validate_presence_of   :identity_url

  context "An incomplete new OpenIdUser" do

    setup do
      @user = create_open_id_user(:email => nil, :name => nil)
    end

    should "be passive" do
      assert @user.passive?
    end

    should "be valid" do
      assert @user.valid?
    end
  end

  context "A valid, new OpenIdUser" do

    setup do
      @user = create_open_id_user
    end

    should "be valid" do
      assert @user.valid?
    end

    should "not be active" do
      assert !@user.active?
    end

    should "be open_id user" do
      assert @user.using_open_id?
    end

    should "be saveable and retrievable" do
      @user.save!
      user = User.find(@user)
      assert_not_nil user
      assert user.valid?
    end

    context "after activation" do
      
      setup do
        # TODO: Why do I have to call activate! a second time?
        @user.activate!
        @user.activate!
      end

      should_validate_presence_of   :identity_url
      should_not_allow_values_for   :email, 'a', 'abcdef', 'a@bcd', 'a@.com'

      should "be active" do
          assert @user.active?
      end

      should "send validation email on activation" do
        assert_equal 1, email_deliveries.size
      end

      context "and after verification" do

        setup do
          ActionMailer::Base.deliveries = []
          @user.verify_email!
        end

        should "be verified" do
          assert @user.verified?
        end

        should "send confirmation email" do
          assert_equal 1, email_deliveries.size
        end
      end

    end

  end 
end

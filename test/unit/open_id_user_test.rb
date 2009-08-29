require File.dirname(__FILE__) + '/../test_helper'

class OpenIdUserTest < ActiveSupport::TestCase

  subject { create_open_id_user }

  should_validate_presence_of   :identity_url
  should_not_allow_values_for   :email, 'a', 'abcdef', 'a@bcd', 'a@.com'

  # This test interacts with presence test and STI with nil values:
  #should_validate_uniqueness_of :identity_url

  context "A valid, new OpenIdUser" do

    setup do
      ActionMailer::Base.deliveries = []
      @user = create_open_id_user
    end

    should "be valid" do
      assert @user.valid?
    end

    context "after activation" do
      setup do
        @user.activate!
      end

      # TODO: Why do I have to call activate! a second time?
      should "be active" do
          @user.activate!
          assert @user.active?
      end

      should "send validation email on activation" do
        assert_equal 1, ActionMailer::Base.deliveries.size
      end

      context "after verification" do

        setup do
          @user.verify_email!
        end

        should "have verified email" do
          assert @user.verified?
        end
      end

    end


    #should "fail to activate if email.nil?" do
    #  @user = create_open_id_user(:email => nil)
    #  @user.activate!
    #  assert_equal :passive.to_s, @user.state
    #end


    #should "be able to authenticate" do
    #  assert_not_nil OpenIdUser.authenticate(@user.identity_url)
    #end

  end 
end

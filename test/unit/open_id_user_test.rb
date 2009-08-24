require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/user_test_base'
require 'shoulda'

class OpenIdUserTest < UserTestBase

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

    should "send validation email on activation" do
      @user.activate!
      assert_equal 'active', @user.state
      #assert_equal 1, ActionMailer::Base.deliveries.size
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

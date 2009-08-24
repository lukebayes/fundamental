require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/user_test_base'
require 'shoulda'

class OpenIdUserTest < UserTestBase

  subject { create_open_id_user }

  should_validate_presence_of   :identity_url
  #should_validate_uniqueness_of :identity_url
  should_not_allow_values_for   :email, 'a', 'abcdef', 'a@bcd', 'a@.com'

  context "A new OpenIdUser" do

    setup do
      ActionMailer::Base.deliveries = []
      @user = create_open_id_user
    end

    should "validate email on activation" do
      @user.activate!
      assert_equal 1, ActionMailer::Base.deliveries.size
    end

    #should "be able to authenticate" do
    #  assert_not_nil OpenIdUser.authenticate(@user.identity_url)
    #end
  end

end

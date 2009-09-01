require "#{File.dirname(__FILE__)}/../test_helper"

class AccountCreationTest < ActionController::IntegrationTest

  context "An unknown user" do
    setup do
      clear_deliveries
    end

    should "be redirected to new session path" do
      get '/'
      assert_redirected_to new_session_path
    end

    should "be able to load new user path" do
      get new_user_path
      assert_response :success
    end

    should "be able to create a new account and verify email address" do
      # Create account:
      post users_path, :user => site_user_hash
      assert_redirected_to root_path
      assert_equal 1, email_deliveries.size
      clear_deliveries

      # Verify Email Address:
      user = User.last
      assert_not_nil user.email_verification_code
      get "/verify_email/#{user.email_verification_code}"
      assert_redirected_to root_path
      assert_equal 1, email_deliveries.size
      assert  flash[:notice] =~ /verified/i
      user.reload
      assert_nil user.email_verification_code
    end
  end

end
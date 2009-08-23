require "#{File.dirname(__FILE__)}/../test_helper"

class CreateUserTest < ActionController::IntegrationTest
  fixtures :users

  def test_should_send_activation_email_on_signup
    assert_difference 'User.count' do # User created
      assert_difference 'ActionMailer::Base.deliveries.size' do # Invitation Sent
        post users_path, :user => default_user_options(:openid_url => 'http://www.example.com')
      end
    end
    user = User.last
    assert_difference 'ActionMailer::Base.deliveries.size' do # Activation Worked
      get activate_path(user.activation_code)
    end
  end
  
  def test_signup_using_open_id
    identity_url = 'http://openid.example.com'
    stub_open_id_creation identity_url
    user = nil

    assert_difference 'User.count' do
      # Create the new openid user
      post users_path, :openid_url => identity_url
      user = User.last
      # Redirect to edit path
      assert_redirected_to edit_user_path(user)
    end

    # Commit the edit with a valid email address
    put user_path(user), :user => default_user_options(:email => 'abc@example.com', :password => nil, :password_confirmation => nil)

    user.reload 
    # Ensure the newly created user is valid
    assert user.valid?, "Should be valid, but has: #{user.errors.full_messages}"
  end
end

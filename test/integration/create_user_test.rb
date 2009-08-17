require "#{File.dirname(__FILE__)}/../test_helper"

class CreateUserTest < ActionController::IntegrationTest
  fixtures :users

  def test_should_send_activation_email_on_signup
    assert_difference 'User.count' do # User created
      assert_difference 'ActionMailer::Base.deliveries.size' do # Invitation Sent
        post users_path, :user => default_user(:openid_url => 'http://www.example.com')
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

    assert_difference 'User.count' do
      post users_path, :openid_url => identity_url
      user = User.last
      assert_redirected_to edit_user_path(user)
    end

    put users_path, :user => default_user(:password => nil, :password_confirmation => nil)

    user = User.last

    assert user.valid?
  end
end

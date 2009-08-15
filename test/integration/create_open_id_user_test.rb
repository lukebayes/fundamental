require "#{File.dirname(__FILE__)}/../test_helper"

class CreateOpenIdUserTest < ActionController::IntegrationTest
  fixtures :users

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

require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < ActionController::TestCase

  fixtures :users

  context "on GET to :new" do
    setup { get :new }

    should_assign_to :user
    should_respond_with :success
    should_render_template :new
    should_not_set_the_flash
  end

  context "on POST to :create" do

    context "with a valid SiteUser" do
      setup { post :create, :user => site_user_hash }

      should_assign_to :user
      should_respond_with :redirect

      should "activate user" do
        user = assigns(:user)
        assert_not_nil user
        assert user.active?
      end
    end

    context "with an invalid SiteUser should fail creation because of" do
      [:email, :password, :password_confirmation].each do |field|
        context "nil #{field}" do
          setup { post :create, :user => site_user_hash(field => nil) }
          should_render_template :new
          should_set_the_flash_to(/problem/i)
        end
      end
    end

  end

  context "on GET to :edit" do

    context "without valid user" do
      setup { get :edit, {:id => users(:quentin).id} }
      should_respond_with :redirect
      should_set_the_flash_to /access/
    end

    context "with valid user" do
      setup do
        login_as :quentin
        get :edit, {:id => users(:quentin).id}
      end

      should_assign_to :user
      should_respond_with :success
      should_render_template :edit
      should_not_set_the_flash
    end
  end

  context "on PUT to :update" do

    context "without valid authentication" do
      setup { put :update, :id => users(:quentin).id, :user => {:name => 'New Name'} }
      should_respond_with :redirect
      should_set_the_flash_to /access/
    end

    context "with valid authentication" do
      setup do
        login_as :quentin
        put :update, :id => users(:quentin).id, :user => {:name => 'New Name'}
      end

      should_respond_with :redirect
      should_set_the_flash_to /updated/
    end

  end

  #def setup
  #  @controller = UsersController.new
  #  @request    = ActionController::TestRequest.new
  #  @response   = ActionController::TestResponse.new
  #end
  #
  #def test_should_allow_signup
  #  assert_difference 'User.count' do
  #    create_user
  #    assert_response :redirect
  #  end
  #end
  #
  #def test_should_require_email_on_signup
  #  assert_no_difference 'User.count' do
  #    create_user(:email => nil)
  #    assert assigns(:user).errors.on(:email)
  #    assert_response :success
  #  end
  #end
  #
  #def test_should_require_password_on_signup
  #  assert_no_difference 'User.count' do
  #    create_user(:password => nil)
  #    assert assigns(:user).errors.on(:password)
  #    assert_response :success
  #  end
  #end
  #
  #def test_should_require_password_confirmation_on_signup
  #  assert_no_difference 'User.count' do
  #    create_user(:password_confirmation => nil)
  #    assert assigns(:user).errors.on(:password_confirmation)
  #    assert_response :success
  #  end
  #end
  #
  #def test_should_sign_up_user_in_active_state
  #  create_user
  #  assigns(:user).reload
  #  assert assigns(:user).active?, 'User should be active'
  #end
  #
  #def test_should_sign_up_user_with_email_verification_code
  #  create_user
  #  assigns(:user).reload
  #  assert_not_nil assigns(:user).email_verification_code
  #end
  #
  #def test_should_verify_email
  #  aaron = users(:aaron)
  #  assert !aaron.verified?, "Aaron should not be verified"
  #  get :verify_email, :email_verification_code => aaron.email_verification_code
  #  assert_not_nil flash[:notice]
  #  assert_redirected_to root_path
  #  #assert aaron.verified?, "Aaron should now be verified"
  #end
  #
  #def test_should_not_verify_with_blank_key
  #  assert_no_difference 'ActionMailer::Base.deliveries.size' do
  #    get :verify_email, :email_verification_code => ''
  #  end
  #end
  #
  #def test_should_send_email_on_signup
  #  assert_difference 'ActionMailer::Base.deliveries.size' do
  #    create_user
  #  end
  #end
  #
  #def test_using_open_for_signup_should_work
  #  identity_url = 'http://openid.example.com'
  #  stub_open_id_creation identity_url
  #
  #  assert_difference 'User.count' do
  #    assert_difference 'ActionMailer::Base.deliveries.size' do
  #      post :create, :user => {:identity_url => identity_url}
  #      user = User.last
  #      assert_redirected_to edit_user_path(user)
  #    end
  #  end
  #end
  #
  #def test_should_fail_with_existing_open_id_for_signup
  #  assert_no_difference 'User.count' do
  #    assert_no_difference 'ActionMailer::Base.deliveries.size' do
  #      post :create, :user => {:identity_url => 'http://openid.example.com/sean.hannity'}
  #      #assert_redirected_to new_session_path
  #    end
  #  end
  #end
  #
  #protected
  #
  #def create_user(options = {})
  #  post :create, :user => default_user_options(options)
  #end
end

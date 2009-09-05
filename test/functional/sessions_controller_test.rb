require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < ActionController::TestCase

  fixtures :users

  context "POST to :create" do

    context "with known user" do
      setup { @user = users(:quentin) }

      should "authenticate with valid SiteUser credentials" do
        post :create, :email => @user.email, :password => 'test'
        assert_equal @user.id, session[:user_id]
        assert_nil flash[:error]
        assert_response :redirect
      end

      should "not authenticate with bad password" do
        post :create, :email => @user.email, :password => 'bad password'
        assert_nil session[:user_id]
        assert_not_nil flash[:error]
        assert_response :success
      end

      should "remember me" do
        post :create, :email => @user.email, :password => 'test', :remember_me => '1'
        assert_not_nil @response.cookies["auth_token"]
      end

      should "not remember me" do
        post :create, :email => @user.email, :password => 'test', :remember_me => '0'
        assert_nil @response.cookies['auth_token']
      end

    end

  end

  context "GET to :destroy" do

    should "logout" do
      login_as :quentin
      get :destroy
      assert_nil session[:user_id]
      assert_response :redirect
    end

    should "delete token on logout" do
      login_as :quentin
      delete :destroy
      assert_nil @response.cookies['auth_token']
    end

  end

  context "GET to :new" do

    setup do
      @user = users(:quentin)
    end

    should "login with cookie" do
      @user.remember_me
      @request.cookies['auth_token'] = cookie_for(:quentin)
      get :new
      assert @controller.send(:logged_in?)
    end

    should "not login with expired cookie" do
      @user.remember_me
      @user.update_attribute :remember_token_expires_at, 5.minutes.ago
      get :new
      assert !@controller.send(:logged_in?)
    end

    should "no login with invalid cookie" do
      @user.remember_me
      @request.cookies['auth_token'] = auth_token('invalid_auth_token')
      get :new
      assert !@controller.send(:logged_in?)
    end
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end
end

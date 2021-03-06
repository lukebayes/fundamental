require File.dirname(__FILE__) + '/../test_helper'

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

      should_create :user
      should_assign_to :user
      should_respond_with :redirect

      should "activate user" do
        user = assigns(:user)
        assert_not_nil user
        assert user.active?
      end
    end

    context "with an invalid SiteUser" do
      [:email, :password, :password_confirmation].each do |field|
        context "and missing #{field}" do
          setup { post :create, :user => site_user_hash(field => nil) }

          should_render_template :new
          should "fail validations" do
            assert_validation_failure(assigns(:user), field)
          end
        end
      end
    end

    context "with a valid OpenIdUser" do
      setup do
        openid_url = 'http://openid.example.com'
        stub_open_id_creation openid_url
        post :create, :openid_url => openid_url
      end

      should_create :user
      should_assign_to :user
      should_render_template :edit
    end

  end

  context "on GET to :edit" do

    context "without authenticated user" do
      setup { get :edit, {:id => users(:quentin).id} }
      should_require_login
    end

    context "with authenticated user" do
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

  context "on POST to :send_verification" do

    context "without authenticated user" do
      setup { post :send_verification, :id => users(:quentin).id }
      should_require_login
    end

    context "with authenticated user" do
      setup { login_as :quentin }

      should "send email" do
        post :send_verification, :id => users(:quentin).id
        assert_equal 1, email_deliveries.size
      end
    end

  end

  context "on PUT to :update" do

    context "without authenticated user" do
      setup { put :update, :id => users(:quentin).id, :user => {:name => 'New Name'} }
      should_require_login
    end

    context "with authenticated user" do
      setup do
        login_as :quentin
      end

      context "allow name change" do
        setup do
          put :update, :id => users(:quentin).id, :user => {:name => 'New Name'}
        end

        should_respond_with :redirect
        should_set_the_flash_to /updated/
      end

      should "remove verified on email change" do
        user = users(:quentin)
        assert user.verified?
        put :update, :id => user.id, :user => {:email => 'abc@example.com'}
        user.reload
        assert user.active?
      end
    end

  end

  context "on GET to :verify_email" do

    context "with valid unverified user" do
      setup do
        post :create, :user => site_user_hash
        assert User.last.active?
        get :verify_email, :email_verification_code => User.last.email_verification_code
      end

      should "send verification email" do
        user = User.last
        assert_equal 2, email_deliveries.size
        assert user.verified?
        assert_nil user.email_verification_code
      end
    end
    
  end
end

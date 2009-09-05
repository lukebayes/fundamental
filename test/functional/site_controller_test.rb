require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class SiteControllerTest < ActionController::TestCase

  context "GET to :index" do

    context "with no user" do
      setup { get :index }
      should_require_login
    end

    context "with valid user" do
      setup do
        login_as(:quentin)
        get :index
      end

      should_respond_with :success
    end
  end

end

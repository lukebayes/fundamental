module AuthenticatedTestHelper

  def self.included(receiver)
    receiver.extend ClassMethods
    receiver.send :include, InstanceMethods
  end

  module InstanceMethods

    def login_as(user)
      @request.session[:user_id] = user ? users(user).id : nil
    end

    def authorize_as(user)
      @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).email, 'test') : nil
    end

  end

  module ClassMethods

    def should_require_login
      should "require login" do
        assert_redirected_to(new_session_path)
      end
    end

  end
end

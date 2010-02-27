class UsersController < ApplicationController
  include UsersHelper
  
  before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:edit, :update, :suspend, :unsuspend, :destroy, :purge, :send_verification]
  before_filter :authorized?, :only => [:edit, :update, :send_verification]

  rescue_from SocketError, :with => :on_socket_error

  def new
    @user = User.new
  end

  def edit
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with
    # request forgery protection.
    # uncomment at your own risk
    # reset_session

    if(!using_open_id?)
      create_site_user
    else
      create_open_id_user(params[:openid_url])
    end
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = "Your account has been updated."
      activate_if_passive(@user)
      redirect_to root_path
    else
      render :action => 'edit'
    end
  end

  def send_verification
    flash[:notice] = "We have sent an email to #{@user.email}, please check your email and click on the link to verify this address."
    UserMailer.deliver_email_verification(@user)
    redirect_back_or_default
  end

  def verify_email
    self.current_user = (params[:email_verification_code].blank?) ? false : User.find_by_email_verification_code(params[:email_verification_code])
    if logged_in?
      current_user.verify_email!
      flash[:notice] = "Your email address has been verified."
    else
      # TODO: Add support for resending a new code:
      flash[:notice] = "We were unable to verify your email with the code provided."
    end
    redirect_back_or_default
  end

  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end

  protected

  def find_user
    @user = User.find(params[:id])
  end

  def authorized?
    (current_user == @user) || access_denied
  end

  def create_site_user
    @user = User.new(params[:user])
    if(activate_site_user(@user))
      flash[:notice] = 'Your account has been created'
      self.current_user = @user
      redirect_back_or_default
    else
      render :new
    end
  end

  def socket_error?
    @socket_error || false
  end

  def on_socket_error(error)
    @socket_error = true
    flash[:error] = "There was a problem sending your email, please try again."
    redirect_back_or_default
  end

  def activate_site_user(user)
    return false if !user.valid?

    # TODO: Why do I have to call activate twice?!
    user.activate!
    user.activate!
  end

  # openid_url is the general target for openid services
  # identity_url is the user-specific auth url
  def create_open_id_user(openid_url)
    authenticate_with_open_id(openid_url, :return_to => open_id_create_url, :required => open_id_required_fields) do |result, identity_url, registration|
      if result.successful?

        if(OpenIdUser.exists_for_identity_url?(identity_url))
          flash[:error] = "We already have an account for that user, please try signing in."
          redirect_to new_session_path
          return false
        end

        finish_creating_open_id_user get_options_from_open_id_params(params, identity_url) 
      else
        @user = User.new
        failed_creation(result.message || "There was a problem with the OpenID service.")
      end
    end
  end

  def finish_creating_open_id_user(attributes)
    @user = User.create(attributes)
    self.current_user = @user
    flash[:notice] = "Please finish this last step to complete creating your account."
    render :action => 'edit'
  end

  def failed_creation(message = 'There was an error creating your account.')
    flash[:error] = message
    render :action => 'new'
  end

  def activate_if_passive(user)
    if(user.passive?)
      user.activate!
      user.activate!
    end
  end
end

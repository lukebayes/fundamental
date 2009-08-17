class UsersController < ApplicationController
  include UsersHelper
  
  before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:edit, :update, :suspend, :unsuspend, :destroy, :purge]
  
  def new
    @user = User.new
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      if(@user.save)
        #if(!@user.active?)
        #  update_openid_user(@user, params)
        #  return
        #else
          flash[:notice] = "Your account is now updated."
          redirect_back_or_default
          return
        #end
      end
    end
    # flash[:error] = "There was a problem updating your account"
    render :action => 'edit', :id => @user
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    if !using_open_id?
      @user = create_user(params[:user])
      @user.register!
      if @user.errors.empty?
        flash[:notice] = "Thanks for signing up, please check your email to finish account activation."
        self.current_user = @user
        redirect_back_or_default
      else
        render :action => 'new'
      end
    else
      create_open_id_user
    end
  end

  def activate
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate!
      flash[:notice] = "Sign up is complete!"
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

  #def using_open_id?
  #  !params[:openid_url].blank?
  #end
  
  def find_user
    @user = User.find(params[:id])
  end

  def create_user(attributes)
    User.new(attributes)    
  end

  def create_open_id_user
    authenticate_with_open_id(params[:identity_url], :return_to => open_id_create_url, :required => open_id_required_fields) do |result, identity_url, registration|
      if result.successful?
        finish_creating_open_id_user get_options_from_open_id_params(params, identity_url)
      else
        @user = User.new
        failed_creation(@user, result.message || "There was a problem with the OpenID service.")
      end
    end
  end

  def open_id_user_exists?(user)
    !User.find_by_identity_url(user.identity_url).nil?
  end

  def finish_creating_open_id_user(attributes)
    @user = User.new(attributes)
    if(open_id_user_exists?(@user))
      flash[:error] = "We already have an account for that user, please try Signing in."
      # TODO: Just go ahead and log them in...
      redirect_to new_session_path
      return
    end

    @user.update_attributes!(attributes)
    self.current_user = @user
    flash[:notice] = "You are now signed in, let's finish creating your account."
    @user.valid?
    return redirect_to(edit_user_path(@user))
  end

  def failed_creation(user = nil, message = 'Sorry, there was an error creating your account')
    flash[:error] = message
    @user = user || User.new
    render :action => 'new'
  end
end

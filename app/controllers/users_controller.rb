class UsersController < ApplicationController
  
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
          flash[:notice] = "Your account has been saved"
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

    @user = User.new(params[:user])
    @user.register! if @user.valid?
    if @user.errors.empty?
      flash[:notice] = "Thanks for signing up, please check your email to finish account activation."
      self.current_user = @user
      redirect_back_or_default
    else
      render :action => 'new'
    end
  end

  def activate
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate!
      flash[:notice] = "Signup complete!"
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

end

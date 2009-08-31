# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController

  def new
  end

  def create
    if(!using_open_id?)
      self.current_user = SiteUser.authenticate(params[:email], params[:password])
      if logged_in?
        if params[:remember_me] == "1"
          current_user.remember_me unless current_user.remember_token?
          cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        end
        redirect_back_or_default
        flash[:notice] = "Logged in successfully"
      else
        flash[:error] = "Authentication failed, please try again."
        render :action => 'new'
      end
    else
      create_session_from_identity_url(params[:identity_url])
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to new_session_path
  end

  protected

  def create_session_from_identity_url(identity_url)
    authenticate_with_open_id(identity_url, :return_to => open_id_complete_url) do |result, identity_url, registration|
      puts "inside closure with successful?: #{result.successful?}"
      if result.successful?
        user = User.find_by_identity_url(identity_url)
        if(user.nil?)
          flash[:error] = "Unable to find an account with that identity url, did you mean to create a new account instead?"
          redirect_to new_user_path
        else
          flash[:notice] = "Welcome back #{user.label}!"
          redirect_back_or_default
        end
      else
        flash[:error] = "Open ID authentication failed."
        redirect_to new_session_path
      end
    end
  end
end

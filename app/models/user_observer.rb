class UserObserver < ActiveRecord::Observer

  def after_save(user)
    if(user.recently_verified?)
      UserMailer.deliver_email_confirmation(user)
    elsif(user.email_changed? && !user.email.blank?)
      UserMailer.deliver_email_verification(user)
    end
  end

end

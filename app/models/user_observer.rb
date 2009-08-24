class UserObserver < ActiveRecord::Observer

  def after_save(user)
    if(user.email_changed? && !user.email.blank?)
      UserMailer.deliver_email_verification(user)
    end

    if(user.recently_verified_email?)
      UserMailer.deliver_email_confirmation(user)
    end
  end

end

class UserMailer < ActionMailer::Base

  def email_verification(user)
    setup_email(user)
    @subject    += ': Please verify your email address'
    @body[:url]  = "#{APP_CONFIG[:site_url]}/verify_email/#{user.email_verification_code}"
  end
  
  def email_confirmation(user)
    setup_email(user)
    @subject    += ': Your email address has been verified!'
    @body[:url]  = APP_CONFIG[:site_url]
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = APP_CONFIG[:admin_email]
      @subject     = APP_CONFIG[:site_name]
      @sent_on     = Time.now.utc
      @body[:user] = user
    end
end

class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += I18n.t('restful_authentication.activation_required_email_subject')
  
    @body[:url]  = "http://YOURSITE/activate/#{user.activation_code}"
  
  end

  def activation(user)
    setup_email(user)
    @subject    += I18n.t('restful_authentication.activation_complete_email_subject')
    @body[:url]  = "http://YOURSITE/"
  end

  def password_reset_notification(user)
    setup_email(user)
    @subject    += I18n.t('restful_authentication.password_reset_email_subject')
    @body[:url]  = "http://beta.golometrics.com/reset_password/#{user.password_reset_code}"
  end

  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "do-not-reply@golometrics.com"
      @subject     = "beta.golometrics.com password reset request"
      @sent_on     = Time.now
      @body[:user] = user
    end
end

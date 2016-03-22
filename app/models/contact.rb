class Contact < ActionMailer::Base
  def contact(name, email, subject, message, copy_recipient=false)
    if copy_recipient
      recipients email
      from "do-not-reply@golometrics.com"
    else
      recipients "beta@golometrics.com"
      reply_to email
      from email
    end
    subject "Customer contact email: #{subject}"
    body :name => name, :message => message, :email => email, :copy_recipient => copy_recipient
  end

end

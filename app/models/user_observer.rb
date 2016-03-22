class UserObserver < ActiveRecord::Observer
  def after_create(user)
  end

  def after_save(user)
    UserMailer.deliver_password_reset_notification(user) if user.recently_password_reset_requested?
  end
end

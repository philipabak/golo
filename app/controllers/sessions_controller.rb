# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :login_required, :only => [:new, :create]

  # render new.rhtml
  def new
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:email], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      if request.format == :mobile
        redirect_to dashboard_path
      else
        redirect_back_or_default('/dashboard')
      end
      flash[:notice] = I18n.t('restful_authentication.logged_in')
    else
      note_failed_signin
      @email       = params[:email]
      @remember_me = params[:remember_me]
      if request.format == :mobile
        redirect_to :back
      else
        render :action => 'new'
      end
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = I18n.t('restful_authentication.logged_out')
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = I18n.t('restful_authentication.login_failed', :email => params[:email])
    logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end

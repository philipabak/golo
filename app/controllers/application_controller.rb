# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  before_filter :adjust_for_group
  before_filter :adjust_format_for_iphone
  before_filter :login_required
  before_filter :check_group_access
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout 'common'

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  protected

  def access_denied
    redirect_to "/"
  end

  # store the grouping in the request. Determine grouping from server_name prefix
  def adjust_for_group
    puts ">>> SERVER_NAME=#{request.env["SERVER_NAME"]}"
    if request.env["SERVER_NAME"] =~ /^(.*?)\./
      prefix = $1
      @grouping = Grouping.find(:first, :conditions=>["prefix=?", prefix]) || Grouping.default_grouping
    else
      @grouping = Grouping.default_grouping
    end
  end

  # check that current_user belongs to the current grouping. If not: logout
  def check_group_access
    if current_user
      if current_user.grouping.id != @grouping.id
        logout_killing_session!
        redirect_to('/')
      end
    end
  end

  def adjust_format_for_iphone
    request.format = :mobile if @grouping.prefix != 'uptown' and (iphone_request? or android_request? or mobile_server_request?)
  end

  def iphone_request?
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
  end

  def android_request?
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/Android/]
  end

  def mobile_server_request?
    request.env["SERVER_NAME"] =~ /^.*?\.mobile\./
  end
end

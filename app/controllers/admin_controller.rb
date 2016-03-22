class AdminController < ApplicationController
  layout 'admin'

  before_filter :jquery_noconflict
  before_filter :basic_auth
  
  def jquery_noconflict
    ActionView::Helpers::PrototypeHelper.const_set(:JQUERY_VAR, 'jQuery')
  end

  private

  def basic_auth
    authenticate_or_request_with_http_basic do |id, password| 
      id == "goloadmin" && password == "$gol0zorr0"
    end
  end
end

class HomeController < ApplicationController
  layout 'common'
  skip_before_filter :login_required

  def index
    #if logged_in?
      #redirect_to :controller => 'users', :action => 'dashboard'
    #end
    
    vmt_reduction_per_week = 20
    household_count = 5000
    vmt_red_per_week_households = vmt_reduction_per_week * household_count
    if @grouping.prefix == 'uptown'
      @total_reduction = 676000
      @total_reduction_label = "One Year Uptown Reduction."
    else
      @total_reduction = vmt_red_per_week_households * 52
      @total_reduction_label = "Target reduction for 2010."
    end
  end

  def learn_more
    if @grouping.prefix == "uptown"
      render :action => "learn_more_uptown"
      return
    end
  end

  def learn_more_uptown
  end

  def contact
    if request.post?
      if params[:name].blank? or params[:mail].blank? or params[:subject].blank? or params[:message].blank?
        flash[:error] = "Please fill out all of the required fields."
        redirect_to :back
        return
      end

      Contact.deliver_contact params[:name], params[:mail], params[:subject], params[:message]
      Contact.deliver_contact params[:name], params[:mail], params[:subject], params[:message], true if params[:copy]
      
      flash[:notice] = "Thank you for contacting GoLo! We will reply to your email shortly."
      redirect_to :action => "index"
    end
  end

  def mini
    render :layout => "mini"
  end
end

class IllegalOdometerReading < StandardError; end
class NegativeMileage < StandardError; end

class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  layout 'common'
  before_filter :login_required, :only => [ :dashboard, :edit, :update ]
  skip_before_filter :verify_authenticity_token
  

  # render new.rhtml
  def new
    @user = User.new
    @user.vehicles.build
  end
 
  def create
    logout_keeping_session!
    convert_mileage params
    @user = User.new params[:user]
    @user.grouping = @grouping

    success = @user && @user.save

    if success && @user.errors.empty?
      flash[:notice] = I18n.t('restful_authentication.signup_complete_with_activation')
      self.current_user = @user
      redirect_back_or_default dashboard_path
    else
      puts "error! success=#{success} errors=#{@user.errors.inspect}"
      flash[:error]  = I18n.t('restful_authentication.signup_problem')
      render :action => 'new'
    end
  end

  def edit
    @user = User.find params[:id]
    if @user != current_user
      render :status => "400 Bad Request", :layout => false, :text => "400 Bad Request"
      return      
    end
  end

  def update
    @user = User.find params[:id]      
    if @user != current_user
      render :status => "400 Bad Request", :layout => false, :text => "400 Bad Request"
      return      
    end

    begin
      # if the email is changed, save it in the old email field
      # unless it's the first time setting the email,
      # or the email has already changed today
      if params[:user][:email] != @user.email and !@user.email.blank? and @user.old_email.blank?
        params[:user][:old_email] = @user.email
        params[:user][:on_mailing_list] = false
      end
      convert_mileage params
      @user.attributes = params[:user]
      @user.save!
    rescue => e
      puts e.inspect
#      puts e.backtrace
    end

    if @user.errors.empty?
      flash[:notice] = "Your profile has been updated."
      redirect_to :action => 'dashboard'
    else
      flash[:error]  = I18n.t('restful_authentication.signup_problem')
      render :action => 'edit'
    end
  rescue ActiveRecord::RecordInvalid      
    render :action => 'edit'    
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = I18n.t('restful_authentication.signup_complete_and_do_login')
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = I18n.t('restful_authentication.blank_activation_code')
      redirect_back_or_default('/')
    else 
      flash[:error]  = I18n.t('restful_authentication.bogus_activation_code', :model => 'user')
      redirect_back_or_default('/')
    end
  end

  def dashboard
    @weekly_household_mileage = current_user.overall_weekly_mileage || 'N/A'
    @baseline_percentage = current_user.baseline_percentage
    @miles_reduced_total = current_user.miles_reduced_total || '?'
    @co2_reduced_total = current_user.co2_reduced_total || '?'
    @pollutants_reduced_total = current_user.pollutants_reduced_total || '?'
    @gallons_reduced_total = current_user.gallons_reduced_total || '?'
    @dollars_reduced_total = current_user.dollars_reduced_total
    @dollars_reduced_total = @dollars_reduced_total ? "$#{@dollars_reduced_total}" : '?'

    @baseline_level = current_user.initial_weekly_mileage
    @average_golo = @grouping.weekly_mileage_average || 0

    dates = {}
    current_user.vehicles.each { |vehicle|
      last = nil
      vehicle.odometer_readings.each { |reading|
        dates[reading.date] = 0 if dates[reading.date] == nil
        if last.nil?
          # if this is the first data point, use the vehicle's initial milage
          dates[reading.date] += (vehicle.initial_annual_mileage / 52.0).round
        else
          mileage_delta = reading.mileage - last.mileage
          time_delta = reading.date.to_time - last.date.to_time
          dates[reading.date] += (mileage_delta / (time_delta == 0 ? 1 : time_delta) * 1.week).round
        end


        last = reading
      }
    }
    @ymin = 0;
    @ymax = 0;
    your_total_data = []
    dates.each { |k,v|
      your_total_data << [k.to_time.to_i * 1000, v]
      @ymin = v if v < @ymin
      @ymax = v if v > @ymax
    }
    @ymin = @baseline_level if @baseline_level < @ymin
    @ymax = @baseline_level if @baseline_level > @ymax
    @ymin = @average_golo if @average_golo < @ymin
    @ymax = @average_golo if @average_golo > @ymax
    @ymin -= @ymin / 10.0;
    @ymax += @ymax / 10.0;
    your_total_data.sort! { |a,b| a[0] <=> b[0] }

    @time_chart_points = [
                          {
                            #:label => 'your miles/week',
                            :color => '#55BCEB',
                            :data => your_total_data
                          }
                         ].to_json
  end

  def add_vehicle
    count = params[:count].to_i + 1
    @vehicle = Vehicle.new :position => count
  end

  def create_odometer_readings
    params[:odometer_reading][:mileage].each_with_index do |mileage_str, i|
      mileage = mileage_str.gsub(/[^0-9.]/, "").to_i
      unless mileage.zero?
        readings = current_user.vehicles[i].odometer_readings
        fail IllegalOdometerReading unless readings.empty? or mileage >= readings.last.mileage
        fail NegativeMileage if mileage < 0
        readings.create! :mileage => mileage, :date => Date.today
      end
    end

    flash[:notice] = "Thanks for updating your odometer readings!"

  rescue IllegalOdometerReading
    flash[:error] = "You entered a mileage that was less than your previous mileage."
  rescue NegativeMileage
    flash[:error] = "You cannot enter negative mileage."
  ensure
    redirect_to :action => 'dashboard'
  end

  def get_makes
    year = Year.find params[:year_id]
    render :json => year.vehicle_makes.uniq.map{|m| {:text => m.name, :value => m.id}}
  end

  def get_models
    year_id = params[:year_id]
    make_id = params[:make_id]
    render :json => VehicleModel.find_all_by_year_id_and_vehicle_make_id(year_id, make_id).map{|m| {:text => m.select_name, :value => m.id}}
  end

  def reset_password
    @user = User.find_by_password_reset_code(params[:password_reset_code]) unless params[:password_reset_code].nil?
    if @user.nil?
      render :status => "400 Bad Request", :layout => false, :text => "400 Bad Request"
      return      
    end

    if request.post?
      if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
        self.current_user = @user
        @user.reset_password
        flash[:notice] = "Password reset successfully for #{@user.email}"
        redirect_back_or_default('/')
      else
        render :action => :reset
      end
    end
  end
  
  def password_reset_request
    if request.post?
      user = User.find_by_email(params[:email])
      if user
        user.reset_password_request
        flash[:notice] = "Reset code sent to #{user.email}"
      else
        flash[:error] = "#{params[:email]} does not exist in system"
      end
      redirect_back_or_default('/')
    end
  end
  
  protected

  def convert_mileage(params)
    params[:user][:vehicles_attributes].each_pair { |k,v|
      v[:initial_annual_mileage] = v[:initial_annual_mileage].gsub(/[^0-9.]/, "").to_i if v[:initial_annual_mileage]
    }
  end
end

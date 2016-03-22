class VehiclesController < ApplicationController
  layout 'common'
  skip_before_filter :verify_authenticity_token

  def show
    @vehicle = Vehicle.find params[:id]
    if @vehicle.user != current_user
      render :status => "400 Bad Request", :layout => false, :text => "400 Bad Request"
      return      
    end
  end

  def update
    @vehicle = Vehicle.find params[:id]
    if @vehicle.user != current_user
      render :status => "400 Bad Request", :layout => false, :text => "400 Bad Request"
      return      
    end

    params[:vehicle][:odometer_readings_attributes].each_pair { |k,v|
      v[:mileage] = v[:mileage].gsub(/[^0-9.]/, "").to_i if v[:mileage]
    }
    @vehicle.attributes = params[:vehicle]
    @vehicle.save!
    redirect_to dashboard_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'show'
  end
end

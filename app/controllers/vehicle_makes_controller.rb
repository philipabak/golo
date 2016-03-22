class VehicleMakesController < ApplicationController
  def vehicle_dropdowns
    @vehicle_makes = VehicleMake.all.sort_by &:name
    render :template => 'vehicle_makes/vehicle_dropdowns.js.erb', :layout => false
  end
end

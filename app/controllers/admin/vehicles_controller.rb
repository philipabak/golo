class Admin::VehiclesController < AdminController
  active_scaffold :vehicle do |config|
    list = [:user, :position, :vehicle_make, :vehicle_model, :created_at, :updated_at, :initial_annual_mileage]
    config.list.columns = list
    config.show.columns = list
    config.update.columns = list
    config.create.columns = list
    config.update.columns = [:initial_annual_mileage]
    config.actions.exclude :create

    config.nested.add_link "Odometer readings", [:odometer_readings]
  end
end

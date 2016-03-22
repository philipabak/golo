class Admin::OdometerReadingController < AdminController
  active_scaffold :odometer_reading do |config|
    list = [:vehicle, :mileage, :date, :created_at, :updated_at]
    config.list.columns = list
    config.show.columns = list
    config.update.columns = list
    config.create.columns = list
    config.update.columns = [:mileage, :date]
    config.create.columns = [:mileage, :date]

  end
end

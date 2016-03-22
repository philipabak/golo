class OdometerReadingController < ApplicationController
  def create
  end

  def destroy
    @odometer_reading_id = params[:id]
    reading = OdometerReading.find @odometer_reading_id
    reading.destroy
  end
end

require 'acts_as_list'

class Vehicle < ActiveRecord::Base
  belongs_to :user
  acts_as_list :scope => :user

  belongs_to :vehicle_model
  has_many :odometer_readings, :order => 'date,created_at'
  accepts_nested_attributes_for :odometer_readings, :allow_destroy => true

  validates_presence_of     :initial_annual_mileage
  validates_numericality_of :initial_annual_mileage, :only_integer => true

  validates_presence_of     :vehicle_make_id
  validates_presence_of     :vehicle_model_id

  def initial_weekly_mileage
    self.initial_annual_mileage / 52
  end

  def weekly_mileage(date = nil)
    date ||= Date.today
    latest_reading = self.odometer_readings.find :last, :conditions => ["date <= ?", date]
    logger.debug "latest_reading = #{latest_reading}"

    if latest_reading and not latest_reading.new_record?
      last_reading = self.odometer_readings.find :last, :conditions => ["date < ?", (latest_reading.date - 6.days)]

      if latest_reading and last_reading
        miles_traveled = latest_reading.mileage - last_reading.mileage
        time_delta = latest_reading.date.to_time - last_reading.date.to_time
        (miles_traveled / time_delta * 1.week).round
      end
    end
  end

  def total_time
    latest_reading = self.odometer_readings.last

    if latest_reading and not latest_reading.new_record?
      first_reading = self.odometer_readings.find :first

      if latest_reading and first_reading and not latest_reading == first_reading and latest_reading.date and first_reading.date
        latest_reading.date.to_time - first_reading.date.to_time
      end
    end
  end

  def total_miles
    latest_reading = self.odometer_readings.last

    if latest_reading and not latest_reading.new_record?
      first_reading = self.odometer_readings.first

      if latest_reading and first_reading and not latest_reading == first_reading
        latest_reading.mileage - first_reading.mileage
      end
    end
  end

  def overall_weekly_mileage
    if self.total_time and (not self.total_time.zero?) and self.total_miles
      ((self.total_miles / self.total_time) * 1.week).to_i
    end
  end

  def miles_reduced_total
    if self.total_time and self.total_time > 0
      predicted_miles = self.initial_annual_mileage / 1.year * self.total_time
      all_miles_reduced = predicted_miles - self.total_miles
      # convert each vehicle's miles reduced to a common time-frame: this is important since we add them up
      (all_miles_reduced / self.total_time * self.user.account_time).ceil
    end
  end

  def gallons_reduced_total
    if self.miles_reduced_total
      (self.miles_reduced_total / self.vehicle_model.miles_per_gallon).round
    end
  end
  
  def vehicle_make
    vehicle_model.vehicle_make
  end

  def to_s
    [vehicle_model.year, vehicle_model.vehicle_make, vehicle_model].map(&:to_s).join ' '
  end

  def short_name
    "'#{vehicle_model.year.to_s.last(2)} #{vehicle_model}"
  end
end

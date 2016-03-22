class OdometerReading < ActiveRecord::Base
  belongs_to :vehicle

  validates_presence_of :date
  validates_presence_of :mileage
  validates_numericality_of :mileage

  def total_miles_reduced
  end
end

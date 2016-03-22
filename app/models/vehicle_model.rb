class VehicleModel < ActiveRecord::Base
  belongs_to :vehicle_make
  belongs_to :year

  def to_s
    name
  end

  def select_name
    display_name
  end
end

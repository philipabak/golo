class VehicleMake < ActiveRecord::Base
  has_many :vehicle_models
  has_many :years, :through => :vehicle_models

  def to_s
    name
  end
end

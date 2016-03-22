class Year < ActiveRecord::Base
  has_many :vehicle_models
  has_many :vehicle_makes, :through => :vehicle_models, :order => :name

  def to_s
    number.to_s
  end
end

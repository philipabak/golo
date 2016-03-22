require 'spec_helper'

describe Vehicle do
  before(:each) do
    @valid_attributes = {
      :user_id => 1,
      :year => 2007,
      :vehicle_make_id => 1,
      :vehicle_model_id => 1
    }
  end

  #it "should create a new instance given valid attributes" do
    #Vehicle.create!(@valid_attributes)
  #end
  
  it 'should report nil if not enough readings' do
    vehicle = Vehicle.new
    vehicle.weekly_mileage.should be_nil
    vehicle.odometer_readings.build :mileage => 1000
    vehicle.weekly_mileage.should be_nil
  end

  it 'should properly calculate its VMT/week' do
    vehicle = Vehicle.new
    vehicle.odometer_readings.build :mileage => 1000, :created_at => Time.now - 1.week
    vehicle.odometer_readings.build :mileage => 2000, :created_at => Time.now
    vehicle.weekly_mileage.should == 1000
  end

  it 'should properly calculate its VMT/week'
  it 'should properly calculate its VMT/week'
  it 'should properly calculate its VMT/week'
  it 'should properly calculate its VMT/week'
end

require 'spec_helper'

describe VehicleModel do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    VehicleModel.create!(@valid_attributes)
  end
end

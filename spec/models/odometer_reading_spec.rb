require 'spec_helper'

describe OdometerReading do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    OdometerReading.create!(@valid_attributes)
  end
end

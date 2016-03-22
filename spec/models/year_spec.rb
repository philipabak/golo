require 'spec_helper'

describe Year do
  before(:each) do
    @valid_attributes = {
      :number => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Year.create!(@valid_attributes)
  end
end

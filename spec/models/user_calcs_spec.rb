# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe User do
  fixtures :users, :vehicle_makes, :vehicle_models

  describe 'calculating' do
    before do
      @user = create_user
      v1 = @user.vehicles[0]
      v2 = @user.vehicles[1]
      v1.odometer_readings.create! :date => '01-01-2009', :mileage => 5000
      v2.odometer_readings.create! :date => '01-01-2009', :mileage => 2000
      v1.odometer_readings.create! :date => '01-01-2010', :mileage => 5400
      v2.odometer_readings.create! :date => '01-01-2010', :mileage => 2200
    end

    it 'gets total miles reduced right' do
      @user.miles_reduced_total.should == 400
    end
  end

protected
  def create_user(options = {})
    record = User.new({ :address => '1700 Cedar Street', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69', :driver_count => 2}.merge(options))
    record.vehicles.build :vehicle_model => VehicleModel.first, :year => 1995, :initial_annual_mileage => 200
    record.vehicles.build :vehicle_model => VehicleModel.first, :year => 1994, :initial_annual_mileage => 800
    record.save!
    record
  end
end


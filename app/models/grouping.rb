class Grouping < ActiveRecord::Base
  has_many :users

  def self.default_grouping
    @@default_grouping ||= Grouping.find(:all, :order=>"id asc", :limit=>1).first
  end

  def co2_reduced_city_total
    cache_value('co2_reduced_city_total') do
      all_enabled_users.map(&:co2_reduced_total).reject(&:nil?).sum
    end
  end

  def pollutants_reduced_average
    cache_value('pollutants_reduced_average') do
      array = all_enabled_users.map(&:pollutants_reduced_total).reject(&:nil?)
      array.sum / array.size unless array.empty?
    end
  end

  def pollutants_reduced_city_total
    cache_value('pollutants_reduced_city_total') do
      all_enabled_users.map(&:pollutants_reduced_total).reject(&:nil?).sum
    end
  end

  def gallons_reduced_average
    cache_value('gallons_reduced_average') do
      array = all_enabled_users.map(&:gallons_reduced_total).reject(&:nil?)
      array.sum / array.size unless array.empty?
    end
  end

  def gallons_reduced_city_total
    cache_value('gallons_reduced_city_total') do
      all_enabled_users.map(&:gallons_reduced_total).reject(&:nil?).sum
    end
  end

  def dollars_reduced_average
    cache_value('dollars_reduced_average') do
      array = all_enabled_users.map(&:dollars_reduced_total).reject(&:nil?)
      array.sum / array.size unless array.empty?
    end
  end

  def dollars_reduced_city_total
    cache_value('dollars_reduced_city_total') do
      all_enabled_users.map(&:dollars_reduced_total).reject(&:nil?).sum
    end
  end

  def weekly_mileage_average
    miles_array = all_enabled_users.map(&:weekly_mileage).reject(&:nil?)
    miles_array.sum / miles_array.size unless miles_array.empty?
  end

  def miles_reduced_average
    cache_value('miles_reduced_average') do
      miles_array = all_enabled_users.map(&:miles_reduced_total).reject(&:nil?)
      miles_array.sum / miles_array.size unless miles_array.empty?
    end
  end

  def miles_reduced_city_total
    cache_value('miles_reduced_city_total') do
      all_enabled_users.map(&:miles_reduced_total).reject(&:nil?).sum
    end
  end

  def co2_reduced_average
    cache_value('co2_reduced_average') do
      array = all_enabled_users.map(&:co2_reduced_total).reject(&:nil?)
      array.sum / array.size unless array.empty?
    end
  end

  protected
  
  def all_enabled_users
    User.find :all, :conditions => ["enabled = true and grouping_id=?", self.id]
  end

  private

  def cache_value(key_prefix)
    key = "#{key_prefix}_#{self.id}"
    unless defined? CACHE and output = CACHE.get(key)
      output = yield
      CACHE.set(key, output, 1.minute) if defined? CACHE
    end
    return output
  end

end

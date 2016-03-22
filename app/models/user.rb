require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  DOLLARS_PER_GALLON = 3.92
  CO2_PER_GALLON = 25
  POLLUTANTS_PER_MILE = 0.0179558

  belongs_to :grouping
  has_many :vehicles, :order => 'position'
  accepts_nested_attributes_for :vehicles, :allow_destroy => true

  #validates_presence_of     :login
  #validates_length_of       :login,    :within => 3..40
  #validates_uniqueness_of   :login
  #validates_format_of       :login,    :with => Authentication.login_regex, :message => :bad_login

  #validates_format_of       :name,     :with => Authentication.name_regex,  :message => :bad_name, :allow_nil => true
  #validates_length_of       :name,     :maximum => 100

  validates_presence_of     :address
  validates_length_of       :address,   :minimum => 4

  validates_presence_of     :state

  validates_presence_of     :postal_code
  validates_length_of       :postal_code,   :minimum => 5

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => :bad_email

  validates_presence_of     :driver_count
  validates_numericality_of :driver_count, :only_integer => true

  validates_acceptance_of :accept_terms, :message => "You must accept the terms and conditions"

  before_create :make_activation_code 

  attr_accessible :email, :username, :password, :password_confirmation, :address, :driver_count, :vehicles_attributes, :state, :postal_code, :accept_terms, :on_mailing_list, :old_email
  attr_accessor :accept_terms

  validate :must_have_vehicle 

  def must_have_vehicle 
    errors.add_to_base("Must have at least one car") if self.vehicles.empty?
  end 

  # Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def active?
    # the existence of an activation code means they have not activated yet
    #activation_code.nil?
    true
  end


  def reset_password_request
    @password_reset_requested = true
    self.make_password_reset_code
    save(false)
  end

  def reset_password
    self.password_reset_code = nil
    save
  end

  #used in user_observer
  def recently_password_reset_requested?
    @password_reset_requested
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    #u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email] # need to get the salt
    u = find_by_email email # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  #def login=(value)
    #write_attribute :login, (value ? value.downcase : nil)
  #end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def overall_weekly_mileage
    vehicle_total :overall_weekly_mileage
  end

  def weekly_mileage(date = nil)
    vehicle_data = vehicles.map{|v|v.weekly_mileage(date)}.compact
    vehicle_data.sum unless vehicle_data.empty?
  end

  def initial_weekly_mileage
    vehicle_total :initial_weekly_mileage
  end

  def initial_annual_mileage
    vehicle_total :initial_annual_mileage
  end

  def baseline_percentage
    if overall_weekly_mileage and initial_weekly_mileage and not initial_weekly_mileage.zero?
      ((overall_weekly_mileage.to_f / initial_weekly_mileage) * 100).round - 100
    end
  end

  def miles_reduced_total
    vehicle_total :miles_reduced_total
  end

  def co2_reduced_total
    gallons_reduced = self.gallons_reduced_total
    (gallons_reduced * CO2_PER_GALLON).round if gallons_reduced
  end

  def pollutants_reduced_total
    miles_reduced = self.miles_reduced_total
    (miles_reduced * POLLUTANTS_PER_MILE).round if miles_reduced
  end

  def gallons_reduced_total
    vehicle_total :gallons_reduced_total
  end

  def dollars_reduced_total
    gallons_reduced = self.gallons_reduced_total
    (gallons_reduced * DOLLARS_PER_GALLON).round if gallons_reduced
  end

  def account_time
    longest_time = 0
    vehicles.each { |v|
      longest_time = v.total_time if v.total_time and v.total_time > longest_time
    }
    return longest_time
  end

  def title_possessive
    username.blank? ? "Your" : "#{username.capitalize}'s"
  end

  protected

  def vehicle_total(msg)
    vehicle_data = self.vehicles.map(&msg).compact
    vehicle_data.sum unless vehicle_data.empty?
  end

  #def average(msg)
    #array = all_enabled_users.map(&msg).reject(&:nil?)
    #array.sum / array.size unless array.empty?
  #end


  def make_activation_code
    self.activation_code = self.class.make_token
  end

  def make_password_reset_code
    self.password_reset_code = self.class.make_token
  end

  # without this, save() complains about "accept_terms"
#  def method_missing(symbol, *params)
#    if (symbol.to_s =~ /^(.*)_before_type_cast$/)
#      send $1
#    else
#      super
#    end
#  end


  private

  def self.cache_value(key)
    unless defined? CACHE and output = CACHE.get(key)
      output = yield
      CACHE.set(key, output, 1.minute) if defined? CACHE
    end
    return output
  end
end

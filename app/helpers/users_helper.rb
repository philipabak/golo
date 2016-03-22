module UsersHelper
  
  #
  # Use this to wrap view elements that the user can't access.
  # !! Note: this is an *interface*, not *security* feature !!
  # You need to do all access control at the controller level.
  #
  # Example:
  # <%= if_authorized?(:index,   User)  do link_to('List all users', users_path) end %> |
  # <%= if_authorized?(:edit,    @user) do link_to('Edit this user', edit_user_path) end %> |
  # <%= if_authorized?(:destroy, @user) do link_to 'Destroy', @user, :confirm => 'Are you sure?', :method => :delete end %> 
  #
  #
  def if_authorized?(action, resource, &block)
    if authorized?(action, resource)
      yield action, resource
    end
  end

  #
  # Link to user's page ('users/1')
  #
  # By default, their login is used as link text and link title (tooltip)
  #
  # Takes options
  # * :content_text => 'Content text in place of user.login', escaped with
  #   the standard h() function.
  # * :content_method => :user_instance_method_to_call_for_content_text
  # * :title_method => :user_instance_method_to_call_for_title_attribute
  # * as well as link_to()'s standard options
  #
  # Examples:
  #   link_to_user @user
  #   # => <a href="/users/3" title="barmy">barmy</a>
  #
  #   # if you've added a .name attribute:
  #  content_tag :span, :class => :vcard do
  #    (link_to_user user, :class => 'fn n', :title_method => :login, :content_method => :name) +
  #          ': ' + (content_tag :span, user.email, :class => 'email')
  #   end
  #   # => <span class="vcard"><a href="/users/3" title="barmy" class="fn n">Cyril Fotheringay-Phipps</a>: <span class="email">barmy@blandings.com</span></span>
  #
  #   link_to_user @user, :content_text => 'Your user page'
  #   # => <a href="/users/3" title="barmy" class="nickname">Your user page</a>
  #
  def link_to_user(user, options={})
    raise "Invalid user" unless user
    options.reverse_merge! :content_method => :login, :title_method => :login, :class => :nickname
    content_text      = options.delete(:content_text)
    content_text    ||= user.send(options.delete(:content_method))
    options[:title] ||= user.send(options.delete(:title_method))
    link_to h(content_text), user_path(user), options
  end

  #
  # Link to login page using remote ip address as link content
  #
  # The :title (and thus, tooltip) is set to the IP address 
  #
  # Examples:
  #   link_to_login_with_IP
  #   # => <a href="/login" title="169.69.69.69">169.69.69.69</a>
  #
  #   link_to_login_with_IP :content_text => 'not signed in'
  #   # => <a href="/login" title="169.69.69.69">not signed in</a>
  #
  def link_to_login_with_IP content_text=nil, options={}
    ip_addr           = request.remote_ip
    content_text    ||= ip_addr
    options.reverse_merge! :title => ip_addr
    if tag = options.delete(:tag)
      content_tag tag, h(content_text), options
    else
      link_to h(content_text), login_path, options
    end
  end

  #
  # Link to the current user's page (using link_to_user) or to the login page
  # (using link_to_login_with_IP).
  #
  def link_to_current_user(options={})
    if current_user
      link_to_user current_user, options
    else
      content_text = options.delete(:content_text) || I18n.t('restful_authentication.not_signed_in')
      # kill ignored options from link_to_user
      [:content_method, :title_method].each{|opt| options.delete(opt)} 
      link_to_login_with_IP content_text, options
    end
  end

  def vehicle_years_for_select
    Year.all.map{|y| [y.number,y.id]}
  end

  def makes_for_select(vehicle)
    makes = vehicle.vehicle_model.year.vehicle_makes.uniq.map{|m| [m.name, m.id]}
    options_for_select(makes, vehicle.vehicle_make_id)
  end

  def models_for_select(vehicle)
    models = VehicleModel.find_all_by_year_id_and_vehicle_make_id(vehicle.vehicle_model.year.id, vehicle.vehicle_make.id).map{|m| [m.select_name, m.id]}
    options_for_select(models, vehicle.vehicle_model_id)
  end

  def position_field(form, vehicle)
    hidden_field vehicle, :position, :name => "vehicle[position][]"
  end

  STATE_NAMES = [
           [ "Alabama", "AL" ], 
           [ "Alaska", "AK" ], 
           [ "Arizona", "AZ" ], 
           [ "Arkansas", "AR" ], 
           [ "California", "CA" ], 
           [ "Colorado", "CO" ], 
           [ "Connecticut", "CT" ], 
           [ "Delaware", "DE" ], 
           [ "District Of Columbia", "DC" ], 
           [ "Florida", "FL" ], 
           [ "Georgia", "GA" ], 
           [ "Hawaii", "HI" ], 
           [ "Idaho", "ID" ], 
           [ "Illinois", "IL" ], 
           [ "Indiana", "IN" ], 
           [ "Iowa", "IA" ], 
           [ "Kansas", "KS" ], 
           [ "Kentucky", "KY" ], 
           [ "Louisiana", "LA" ], 
           [ "Maine", "ME" ], 
           [ "Maryland", "MD" ], 
           [ "Massachusetts", "MA" ], 
           [ "Michigan", "MI" ], 
           [ "Minnesota", "MN" ], 
           [ "Mississippi", "MS" ], 
           [ "Missouri", "MO" ], 
           [ "Montana", "MT" ], 
           [ "Nebraska", "NE" ], 
           [ "Nevada", "NV" ], 
           [ "New Hampshire", "NH" ], 
           [ "New Jersey", "NJ" ], 
           [ "New Mexico", "NM" ], 
           [ "New York", "NY" ], 
           [ "North Carolina", "NC" ], 
           [ "North Dakota", "ND" ], 
           [ "Ohio", "OH" ], 
           [ "Oklahoma", "OK" ], 
           [ "Oregon", "OR" ], 
           [ "Pennsylvania", "PA" ], 
           [ "Rhode Island", "RI" ], 
           [ "South Carolina", "SC" ], 
           [ "South Dakota", "SD" ], 
           [ "Tennessee", "TN" ], 
           [ "Texas", "TX" ], 
           [ "Utah", "UT" ], 
           [ "Vermont", "VT" ], 
           [ "Virginia", "VA" ], 
           [ "Washington", "WA" ], 
           [ "West Virginia", "WV" ], 
           [ "Wisconsin", "WI" ], 
           [ "Wyoming", "WY" ]
          ]
  
  def state_options(user)
    options_for_select( [[ "Select a State", "" ]] + STATE_NAMES, user.state )
  end

  def account_time_column(user)
    distance_of_time_in_words_to_now (Time.now - user.account_time.seconds)
  end
end

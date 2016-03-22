RE_User      = %r{(?:(?:the )? *(\w+) *)}
RE_User_TYPE = %r{(?: *(\w+)? *)}

#
# Setting
#

Given "an anonymous user" do
  log_out!
end

Given "$an $user_type user with $attributes" do |_, user_type, attributes|
  create_user! user_type, attributes.to_hash_from_story
end

Given "$an $user_type user named '$email'" do |_, user_type, email|
  create_user! user_type, named_user(email)
end

Given "$an $user_type user logged in as '$email'" do |_, user_type, email|
  create_user! user_type, named_user(email)
  log_in_user!
end

Given "$actor is logged in" do |_, email|
  log_in_user! @user_params || named_user(email)
end

Given "there is no $user_type user named '$email'" do |_, email|
  @user = User.find_by_email(email)
  @user.destroy! if @user
  @user.should be_nil
end

#
# Actions
#
When "$actor logs out" do
  log_out
end

When "$actor registers an account as the preloaded '$email'" do |_, email|
  user = named_user(email)
  user['password_confirmation'] = user['password']
  create_user user
end

When "$actor registers an account with $attributes" do |_, attributes|
  create_user attributes.to_hash_from_story
end


When "$actor logs in with $attributes" do |_, attributes|
  log_in_user attributes.to_hash_from_story
end

#
# Result
#
Then "$actor should be invited to sign in" do |_|
  response.should render_template('/sessions/new')
end

Then "$actor should not be logged in" do |_|
  controller.logged_in?.should_not be_true
end

Then "$email should be logged in" do |email|
  controller.logged_in?.should be_true
  controller.current_user.should === @user
  controller.current_user.email.should == named_user(email)['email']
end

def named_user email
  user_params = {
    'admin'   => {'id' => 1,  'password' => '1234addie', 'email' => 'admin@example.com',       },
    'oona'    => {'password' => '1234oona',  'email' => 'unactivated@example.com', 'address' => '1737 Cedar Street', 'driver_count' => '2', 'initial_annual_mileage' => '37000',
"vehicles_attributes"=>{"0"=>{"vehicle_make_id"=>VehicleModel.find(:first).vehicle_make_id, "year"=>"2007", "vehicle_model_id"=>VehicleModel.find(:first).id}}},
    'reggie'  => {           'password' => 'monkey',    'email' => 'registered@example.com', 'address' => '1737 Cedar Street', 'driver_count' => '1', 'initial_annual_mileage' => '12350',
"vehicles_attributes"=>{"0"=>{"vehicle_make_id"=>VehicleModel.find(:first).vehicle_make_id, "year"=>"2007", "vehicle_model_id"=>VehicleModel.find(:first).id}}}
  }
  user_params[email.downcase]
end

#
# User account actions.
#
# The ! methods are 'just get the job done'.  It's true, they do some testing of
# their own -- thus un-DRY'ing tests that do and should live in the user account
# stories -- but the repetition is ultimately important so that a faulty test setup
# fails early.
#

def log_out
  get '/sessions/destroy'
end

def log_out!
  log_out
  response.should redirect_to('/')
  follow_redirect!
end

def create_user(user_params={})
  @user_params       ||= user_params
  post "/users", :user => user_params
  @user = User.find_by_email(user_params['email'])
end

def create_user!(user_type, user_params)
  user_params['password_confirmation'] ||= user_params['password'] ||= user_params['password']
  create_user user_params
  response.should redirect_to(dashboard_path)
  follow_redirect!

end



def log_in_user user_params=nil
  @user_params ||= user_params
  user_params  ||= @user_params
  post "/session", user_params
  @user = User.find_by_email(user_params['email'])
  controller.current_user
end

def log_in_user! *args
  log_in_user *args
  response.should redirect_to('/')
  follow_redirect!
  #response.should have_flash("notice", /Logged in successfully/)
end

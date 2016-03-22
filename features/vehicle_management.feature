Visitors should be able to manage their list of cars. If they
buy/sell/retire a car, they should be able to reflect that fact in
their profile. Any existing data should be modified accordingly.

#Story: Creating an account
#As an anonymous user
#I want to be able to create an account
#So that I can be one of the cool kids

  #
  # Account Creation: Get entry form
  #
  #Scenario: Anonymous user can start creating an account
  #Given an anonymous user
  #When  he goes to /signup
  #Then  he should be at the 'users/new' page
  #And  the page should look AWESOME
  #And  he should see a <form> containing a textfield: What is your home address?, textfield: Enter your email address, password: Choose a password, password: Verify password, textfield: How many drivers in your household?, textfield:How many miles do you drive each year?, submit: 'Sign up'

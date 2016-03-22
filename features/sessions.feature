Users want to know that nobody can masquerade as them.  We want to extend trust
only to visitors who present the appropriate credentials.  Everyone wants this
identity verification to be as secure and convenient as possible.

Story: Logging in
  As an anonymous user with an account
  I want to log in to my account
  So that I can be myself

  #
  # Log in: get form
  #
  Scenario: Anonymous user can get a login form.
    Given an anonymous user
    When he goes to /login
    Then he should be at the new sessions page
     And  the page should look AWESOME
     And he should see a <form> containing a textfield: Email, password: Password, and submit: 'Log in'
  
  #
  # Log in successfully, but don't remember me
  #
  Scenario: Anonymous user can log in
    Given an anonymous user
     And  an activated user named 'reggie'
    When he creates a singular sessions with email: 'registered@example.com', password: 'monkey', remember me: ''
    Then he should be redirected to the home page
    When he follows that redirect!
    #Then he should see a notice message 'Logged in successfully'
     Then  reggie should be logged in
     And he should not have an auth_token cookie
   
  Scenario: Logged-in user who logs in should be the new one
    Given an activated user named 'reggie'
     And  an activated user logged in as 'oona'
    When he creates a singular sessions with email: 'registered@example.com', password: 'monkey', remember me: ''
    Then he should be redirected to the home page
    When he follows that redirect!
    #Then he should see a notice message 'Logged in successfully'
     Then  reggie should be logged in
     And he should not have an auth_token cookie
  
  #
  # Log in successfully, remember me
  #
  Scenario: Anonymous user can log in and be remembered
    Given an anonymous user
     And  an activated user named 'reggie'
    When he creates a singular sessions with email: 'registered@example.com', password: 'monkey', remember me: '1'
    Then he should be redirected to the home page
    When he follows that redirect!
    #Then he should see a notice message 'Logged in successfully'
     Then  reggie should be logged in
     And he should have an auth_token cookie
	      # assumes fixtures were run sometime
     And his session store should have user_id: 4
   
  #
  # Log in unsuccessfully
  #
  
  Scenario: Logged-in user who fails logs in should be logged out
    Given an activated user named 'oona'
    When he creates a singular sessions with email: 'unactivated@example.com', password: '1234oona', remember me: '1'
    Then he should be redirected to the home page
    When he follows that redirect!
    #Then he should see a notice message 'Logged in successfully'
     Then  oona should be logged in
     And he should have an auth_token cookie
    When he creates a singular sessions with email: 'registered@example.com', password: 'i_haxxor_joo'
    Then he should be at the new sessions page
    #Then he should see an error message 'Couldn't log you in as 'reggie''
     Then he should not be logged in
     And he should not have an auth_token cookie
     And his session store should not have user_id
  
  Scenario: Log-in with bogus info should fail until it doesn't
    Given an activated user named 'reggie'
    When he creates a singular sessions with email: 'registered@example.com', password: 'i_haxxor_joo'
    Then he should be at the new sessions page
    #Then he should see an error message 'Couldn't log you in as 'reggie''
     Then he should not be logged in
     And he should not have an auth_token cookie
     And his session store should not have user_id
    When he creates a singular sessions with email: 'registered@example.com', password: ''
    Then he should be at the new sessions page
    #Then he should see an error message 'Couldn't log you in as 'reggie''
     Then he should not be logged in
     And he should not have an auth_token cookie
     And his session store should not have user_id
    When he creates a singular sessions with email: '', password: 'monkey'
    Then he should be at the new sessions page
    #Then he should see an error message 'Couldn't log you in as '''
     Then he should not be logged in
     And he should not have an auth_token cookie
     And his session store should not have user_id
    When he creates a singular sessions with email: 'leonard_shelby', password: 'monkey'
    Then he should be at the new sessions page
    #Then he should see an error message 'Couldn't log you in as 'leonard_shelby''
     Then he should not be logged in
     And he should not have an auth_token cookie
     And his session store should not have user_id
    When he creates a singular sessions with email: 'registered@example.com', password: 'monkey', remember me: '1'
    Then he should be redirected to the home page
    When he follows that redirect!
    #Then he should see a notice message 'Logged in successfully'
     Then  reggie should be logged in
     And he should have an auth_token cookie
	      # assumes fixtures were run sometime
     And his session store should have user_id: 4


  #
  # Log out successfully (should always succeed)
  #
  Scenario: Anonymous (logged out) user can log out.
    Given an anonymous user
    When he goes to /logout
    Then he should be redirected to the home page
    When he follows that redirect!
    #Then he should see a notice message 'You have been logged out'
     Then he should not be logged in
     And he should not have an auth_token cookie
     And his session store should not have user_id

  Scenario: Logged in user can log out.
    Given an activated user logged in as 'reggie'
    When he goes to /logout
    Then he should be redirected to the home page
    When he follows that redirect!
    #Then he should see a notice message 'You have been logged out'
     Then he should not be logged in
     And he should not have an auth_token cookie
     And his session store should not have user_id

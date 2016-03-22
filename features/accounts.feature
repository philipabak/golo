Visitors should be in control of creating an account and of proving their
essential humanity/accountability or whatever it is people think the
id-validation does.  We should be fairly skeptical about this process, as the
identity+trust chain starts here.

Story: Creating an account
As an anonymous user
I want to be able to create an account
So that I can be one of the cool kids

  #
  # Account Creation: Get entry form
  #
  Scenario: Anonymous user can start creating an account
    Given an anonymous user
    When  he goes to /signup
    Then  he should be at the 'users/new' page
    And  the page should look AWESOME
    And  he should see a <form> containing a textfield: What is your home address?, textfield: Enter your email address, password: Choose a password, password: Verify password, textfield: How many drivers in your household?, textfield:How many miles do you drive each year?, submit: 'Sign up'

  #
  # Account Creation
  #
  Scenario: Anonymous user can create an account
    Given an anonymous user
    And  no user with login: 'Oona' exists
    When  he registers an account as the preloaded 'Oona'
    Then he should be redirected to the dashboard page
    When he follows that redirect!
    #Then show me the page
    And  a user with email: 'unactivated@example.com' should exist
    And  oona should be logged in


  #
  # Account Creation Failure: Account exists
  #


  Scenario: Anonymous user can not create an account replacing an activated account
    Given an anonymous user
    And  an activated user named 'Reggie'
    And  we try hard to remember the user's updated_at, and created_at
    When  he registers an account with password: 'monkey', address: '1737 Cedar Street', driver_count: '2', initial_annual_mileage: '37000', and email: 'registered@example.com'
    Then  he should be at the 'users/new' page
    And  he should see an errorExplanation message 'Email has already been taken'
    And  a user with email: 'registered@example.com' should exist

    And  the user's created_at should stay the same under to_s
    And  the user's updated_at should stay the same under to_s
    And  he should not be logged in

  #
  # Account Creation Failure: Incomplete input
  #
  Scenario: Anonymous user can not create an account without an address
    Given an anonymous user
    And  no user with email: 'unactivated@example.com' exists
    When  he registers an account with password: 'monkey', password_confirmation: 'monkey', address: '', driver_count: '2', initial_annual_mileage: '37000', and email: 'unactivated@example.com'
    Then  he should be at the 'users/new' page
    And  he should     see an errorExplanation message 'Address can't be blank'
    And  no user with email: 'unactivated@example.com' should exist

  Scenario: Anonymous user can not create an account without a driver count
    Given an anonymous user
    And  no user with email: 'unactivated@example.com' exists
    When  he registers an account with password: 'monkey', password_confirmation: 'monkey', address: '1737 Cedar Street', driver_count: '', initial_annual_mileage: '37000', and email: 'unactivated@example.com'
    Then  he should be at the 'users/new' page
    And  he should     see an errorExplanation message 'Driver count can't be blank'
    And  no user with email: 'unactivated@example.com' should exist

  Scenario: Anonymous user can not create an account without base mileage
    Given an anonymous user
    And  no user with email: 'unactivated@example.com' exists
    When  he registers an account with password: 'monkey', password_confirmation: 'monkey', address: '1737 Cedar Street', driver_count: '2', initial_annual_mileage: '', and email: 'unactivated@example.com'
    Then  he should be at the 'users/new' page
    And  he should     see an errorExplanation message 'Initial annual mileage can't be blank'
    And  no user with email: 'unactivated@example.com' should exist

  Scenario: Anonymous user can not create an account with non-numeric driver count
    Given an anonymous user
    And  no user with email: 'unactivated@example.com' exists
    When  he registers an account with password: 'monkey', password_confirmation: 'monkey', address: '1737 Cedar Street', driver_count: 'a2', initial_annual_mileage: '37000', and email: 'unactivated@example.com'
    Then  he should be at the 'users/new' page
    And  he should     see an errorExplanation message 'Driver count is not a number'
    And  no user with email: 'unactivated@example.com' should exist

  Scenario: Anonymous user can not create an account with non-numeric base mileage
    Given an anonymous user
    And  no user with email: 'unactivated@example.com' exists
    When  he registers an account with password: 'monkey', password_confirmation: 'monkey', address: '1737 Cedar Street', driver_count: '2', initial_annual_mileage: 'pie', and email: 'unactivated@example.com'
    Then  he should be at the 'users/new' page
    And  he should     see an errorExplanation message 'Initial annual mileage is not a number'
    And  no user with email: 'unactivated@example.com' should exist

  Scenario: Anonymous user can not create an account with no password
    Given an anonymous user
    And  no user with login: 'Oona' exists
    When  he registers an account with password: '',       password_confirmation: 'monkey', address: '1737 Cedar Street', driver_count: '2', initial_annual_mileage: '37000', and email: 'unactivated@example.com'
    Then  he should be at the 'users/new' page
    And  he should     see an errorExplanation message 'Password can't be blank'
    And  no user with email: 'unactivated@example.com' should exist

  Scenario: Anonymous user can not create an account with no password_confirmation
    Given an anonymous user
    And  no user with login: 'Oona' exists
    When  he registers an account with email: 'unactivated@example.com', password: 'monkey', password_confirmation: '', address: '1737 Cedar Street', driver_count: '2', initial_annual_mileage: '37000', and email: 'unactivated@example.com'
    Then  he should be at the 'users/new' page
    And  he should     see an errorExplanation message 'Password confirmation can't be blank'
    And  no user with email: 'unactivated@example.com' should exist

  Scenario: Anonymous user can not create an account with mismatched password & password_confirmation
    Given an anonymous user
    And  no user with login: 'Oona' exists
    When  he registers an account with password: 'monkey', password_confirmation: 'monkeY', address: '1737 Cedar Street', driver_count: '2', initial_annual_mileage: '37000', and email: 'unactivated@example.com'
    Then  he should be at the 'users/new' page
    And  he should     see an errorExplanation message 'Password doesn't match confirmation'
    And  no user with email: 'unactivated@example.com' should exist

  Scenario: Anonymous user can not create an account with bad email
    Given an anonymous user
    And  no user with login: 'Oona' exists
    When  he registers an account with password: 'monkey', password_confirmation: 'monkey', address: '1737 Cedar Street', driver_count: '2', initial_annual_mileage: '37000', and email: ''
    Then  he should be at the 'users/new' page
    And  he should     see an errorExplanation message 'Email can't be blank'
    And  no user with email: 'unactivated@example.com' should exist
    When  he registers an account with password: 'monkey', password_confirmation: 'monkey', address: '1737 Cedar Street', driver_count: '2', initial_annual_mileage: '37000', and email: 'unactivated@example.com'
    Then he should be redirected to the dashboard page
    When he follows that redirect!
    And  a user with email: 'unactivated@example.com' should exist

    And  oona should be logged in




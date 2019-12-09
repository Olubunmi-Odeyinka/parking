# Sprint 1
Feature: User Login
  As a user
  Such that I want to find parking space
  I want to login to the application

  Scenario: Login to the web page

    Given the following users are registered
      | name              | username | password | role     |
      | Fred Flintstone   | Ben      | 123456   | customer |
      | Barney Rubble     | barney   | 123456   | customer |
      | Raymond Tope      | Sola     | 123456   | customer |
      | Odeyinka Olubunmi | Yinka    | 123456   | customer |
    When I navigate to "login page" i.e. "/#/login"
    And I fill my credentials as username "Sola" and password "123456"
    When I click "Submit" Button with "id" "login_user"
    Then I should be logged in


# Sprint 2
Feature: Interactive search of parking space
  As a user
  Such that I want to search for available parking spaces
  I want to enter destination aadress

  Scenario: Find available parking spaces according to the destination
    Given the following parking spaces
      | id | longitude       | latitude        | status      | user_id    | zone_id     |
      | 1  | 24.77177        | 59.43894        | Booked      | null       | 2           |
      | 2  | 26.722815       | 58.380196       | Available   | null       | 2           |
      | 3  | 26.719978       | 59.43894        | Booked      | null       | 1           |
      | 4  | 26.705402       | 58.386141       | Available   | null       | 1           |
      | 5  | 26.747716       | 58.382181       | Available   | null       | 1           |
      | 6  | 26.714242       | 58.383171       | Available   | null       | 1           |
    And the following registred user
      | id  | name              | username | password | role      |
      | 1   | Fred Flintstone   | Fred     | 123456   | customer  |
    When I am logged in 
    And I am on parking space search page
    And I fill Destination address as "Lossi 2, Tartu"
    When I click submit
    Then I should receieve available parking spaces in 1000 meter radius

  Scenario: Check price info of available parking spaces
    Given the following parking spaces
      | id | longitude       | latitude        | status      | user_id    | zone_id     |
      | 1  | 24.77177        | 59.43894        | Booked      | null       | 2           |
      | 2  | 26.722815       | 58.380196       | Available   | null       | 2           |
      | 3  | 26.719978       | 59.43894        | Booked      | null       | 1           |
      | 4  | 26.705402       | 58.386141       | Available   | null       | 1           |
      | 5  | 26.747716       | 58.382181       | Available   | null       | 1           |
      | 6  | 26.714242       | 58.383171       | Available   | null       | 1           |
    And the following registred user
      | id  | name              | username | password | role      |
      | 1   | Fred Flintstone   | Fred     | 123456   | customer  |
    And the following parking zones
      | id      | zone_type   | hourly_rate   | real_time_rate  |
      | 1       | A           | 2             | 0.16            |
      | 2       | B           | 1             | 0.08            |
    When I am logged in 
    And I am on parking space search page
    And I fill Destination address as "Lossi 2, Tartu"
    When I click submit
    Then I should receieve available parking spaces in 1000 meter radius
    When I click on available parking space
    Then I should recieve the information about parking zone 
    And price info for hourly rate and 5 minute rate

#Sprint 2
Feature: Checking estimation fee
  As a user
  Such that I want to choose parking space
  I want to see estimation fee

  Scenario: Checking estimation fee according to the leaving hour
    Given the following parking spaces
      | id | longitude       | latitude        | status      | user_id    | zone_id     |
      | 1  | 24.77177        | 59.43894        | Booked      | null       | 2           |
      | 2  | 26.722815       | 58.380196       | Available   | null       | 2           |
      | 3  | 26.719978       | 59.43894        | Booked      | null       | 1           |
      | 4  | 26.705402       | 58.386141       | Available   | null       | 1           |
      | 5  | 26.747716       | 58.382181       | Available   | null       | 1           |
      | 6  | 26.714242       | 58.383171       | Available   | null       | 1           |
    And the following registred user
      | id  | name              | username | password | role      |
      | 1   | Fred Flintstone   | Fred     | 123456   | customer  |
    And the following parking zones
      | id      | zone_type   | hourly_rate   | real_time_rate  |
      | 1       | A           | 2             | 0.16            |
      | 2       | B           | 1             | 0.08            |
    When I am logged in 
    And I am on parking space search page
    And I fill Destination address as "Friedrich Reinhold Kreutzwaldi 62, Tartu"
    And I fill intended leaving hour as "2"
    When I click submit
    Then I should receieve one available parking space
    When I click on only available parking space
    Then I should recieve parking estimation fee by hourly rate and 5 minute rate


#Sprint 3
Feature: Start parking using hourly scheme
  As a user
  Such that I have selected suitable parking spot
  I want to start parking using hourly scheme

  Scenario: Paying for hourly scheme parking and parking the car
    Given the following parking spaces
      | id | longitude       | latitude        | status      | user_id    | zone_id     |
      | 1  | 24.77177        | 59.43894        | Booked      | null       | 2           |
      | 2  | 26.722815       | 58.380196       | Available   | null       | 2           |
      | 3  | 26.719978       | 59.43894        | Booked      | null       | 1           |
      | 4  | 26.705402       | 58.386141       | Available   | null       | 1           |
      | 5  | 26.747716       | 58.382181       | Available   | null       | 1           |
      | 6  | 26.714242       | 58.383171       | Available   | null       | 1           |
    And the following registred user
      | id  | name              | username | password | role      | credit_card_number | account_balance | valid_date | cvv |
      | 1   | Fred Flintstone   | Fred     | 123456   | customer  | 378734493671000    | 5000             | 09/20     | 123 |
    And the following parking zones
      | id      | zone_type   | hourly_rate   | real_time_rate  |
      | 1       | A           | 2             | 0.16            |
      | 2       | B           | 1             | 0.08            |
    When I am logged in
    And I am on parking place search page
    And I fill Destination address as "Friedrich Reinhold Kreutzwaldi 62, Tartu"
    And I click submit
    And I click on available parking space
    Then I should recieve parking spot information dialog with parking scheme options 
    When I click on Hour rate on that dialog
    Then I should recieve dialog for inserting parking start and end times
    When I submit the end and start times
    Then I should recieve invoice for parking
    When I click pay
    Then I should have started parking for inserted timeperiod


#Sprint 3
Feature: Start parking using real-time scheme
  As a user
  Such that I have selected suitable parking spot
  I want start parking using real-time scheme

  Scenario: Starting parking using Real-time payment scheme
      Given the following parking spaces
      | id | longitude       | latitude        | status      | user_id    | zone_id     |
      | 1  | 24.77177        | 59.43894        | Booked      | null       | 2           |
      | 2  | 26.722815       | 58.380196       | Available   | null       | 2           |
      | 3  | 26.719978       | 59.43894        | Booked      | null       | 1           |
      | 4  | 26.705402       | 58.386141       | Available   | null       | 1           |
      | 5  | 26.747716       | 58.382181       | Available   | null       | 1           |
      | 6  | 26.714242       | 58.383171       | Available   | null       | 1           |
    And the following registred user
      | id  | name              | username | password | role      | credit_card_number | account_balance | valid_date | cvv |
      | 1   | Fred Flintstone   | Fred     | 123456   | customer  | 378734493671000    | 5000             | 09/20     | 123 |
    And the following parking zones
      | id      | zone_type   | hourly_rate   | real_time_rate  |
      | 1       | A           | 2             | 0.16            |
      | 2       | B           | 1             | 0.08            |
    When I am logged in
    And I am on parking place search page
    And I fill Destination address as "Friedrich Reinhold Kreutzwaldi 62, Tartu"
    And I click submit
    And I click on available parking space
    Then I should recieve parking spot information dialog with parking scheme options 
    When I click on Minute rate on that dialog
    Then I should have started real-time parking 



#Sprint 4
Feature: Extension of hourly payment scheme
  As a user
  Such that I have parked the car using hourly payment
  I want to extend the hourly payment

  Scenario: Getting notification about the end of hourly payment 10 min before the end
    Given the following parking space
      | id | longitude       | latitude        | status      | user_id    | zone_id     |
      | 1  | 24.77177        | 59.43894        | Booked      | null       | 2           |
    And the following registred user
      | id  | name              | username | password | role      | credit_card_number | account_balance | valid_date | cvv | email                     |
      | 1   | Fred Flintstone   | Fred     | 123456   | customer  | 378734493671000    | 5000             | 09/20     | 123 | fred.flintstone@gmail.com |
    And the following parking zones
      | id      | zone_type   | hourly_rate   | real_time_rate  |
      | 1       | A           | 2             | 0.16            |
      | 2       | B           | 1             | 0.08            |
    When it is 10 minutes until the end of parking
    Then I should recieve notification on my email

    Scenario: Extending the hourly payment
      Given the following parking space
        | id | longitude       | latitude        | status      | user_id    | zone_id     |
        | 1  | 24.77177        | 59.43894        | Booked      | null       | 2           |
      And the following registred user
        | id  | name              | username | password | role      | credit_card_number | account_balance | valid_date | cvv | email                     |
        | 1   | Fred Flintstone   | Fred     | 123456   | customer  | 378734493671000    | 5000             | 09/20     | 123 | fred.flintstone@gmail.com |
      And the following parking zones
        | id      | zone_type   | hourly_rate   | real_time_rate  |
        | 1       | A           | 2             | 0.16            |
        | 2       | B           | 1             | 0.08            |
      When it is 10 minutes until the end of parking
      Then I should recieve notification on my email
      When I am logged in
      And I click on Extend next to my active parking
      Then I should recieve dialog for inserting new parking end time
      When I submit new parking end time
      Then I should have started and paid parking for inserted timeperiod


      Scenario: Hourly payment is not extended
        Given the following parking space
          | id | longitude       | latitude        | status      | user_id    | zone_id     |
          | 1  | 24.77177        | 59.43894        | Booked      | null       | 2           |
        And the following registred user
          | id  | name              | username | password | role      | credit_card_number | account_balance | valid_date | cvv | email                     |
          | 1   | Fred Flintstone   | Fred     | 123456   | customer  | 378734493671000    | 5000             | 09/20     | 123 | fred.flintstone@gmail.com |
        And the following parking zones
          | id      | zone_type   | hourly_rate   | real_time_rate  |
          | 1       | A           | 2             | 0.16            |
          | 2       | B           | 1             | 0.08            |
        When it is 2 minutes until the end of parking
        Then the parking space should be made available

#Sprint 4
Feature: End parking using real-time scheme
  As a user
  Such that I have started real-time parking
  I want to end my real-time parking

  Scenario: End parking using real-time payment scheme
    Given the following parking space
      | id | longitude       | latitude        | status      | user_id    | zone_id     |
      | 1  | 24.77177        | 59.43894        | Booked      | null       | 2           |
    And the following registred user
      | id  | name              | username | password | role      | credit_card_number | account_balance | valid_date | cvv | email                     |
      | 1   | Fred Flintstone   | Fred     | 123456   | customer  | 378734493671000    | 5000             | 09/20     | 123 | fred.flintstone@gmail.com |
    And the following parking zones
      | id      | zone_type   | hourly_rate   | real_time_rate  |
      | 1       | A           | 2             | 0.16            |
      | 2       | B           | 1             | 0.08            |
    When I am logged in
    And I am have parked my car using real-time scheme
    And I am on my active parking page
    And I click on end parking
    Then I should recieve invoice for parking
    When I click pay
    Then I am moved to customer page

# Sprint 5
Feature: Activating monthly payment
  As a user
  Such that I want to pay using monthly scheme
  I want to activate monthly payment option

  Scenario: Choose monthly payment option
    Given the following registred user
      | id  | name              | username | password | role      | credit_card_number | account_balance | valid_date | cvv | email                     | monthly_payment      |
      | 1   | Fred Flintstone   | Fred     | 123456   | customer  | 378734493671000    | 5000             | 09/20     | 123 | fred.flintstone@gmail.com | false                |
    When I am logged in
    And I check the box for choosing monthly payment scheme
    And I click on save changes Button
    Then I have activated monthly payment scheme


# Sprint 5
Feature: Park car using real-time parking scheme with monthly payment option
  As a user
  Such that I have activated monthly payment scheme
  I want to park car using real-time parking
  
  Scenario: Use real-time parking with monthly payment activated
    Given the following parking space
      | id | longitude       | latitude        | status      | user_id    | zone_id     |
      | 1  | 24.77177        | 59.43894        | Booked      | null       | 2           |
    And the following registred user
      | id  | name              | username | password | role      | credit_card_number | account_balance | valid_date | cvv | email                     | monthly_payment      |
      | 1   | Fred Flintstone   | Fred     | 123456   | customer  | 378734493671000    | 5000             | 09/20     | 123 | fred.flintstone@gmail.com | false                |
    And the following parking zones
      | id      | zone_type   | hourly_rate   | real_time_rate  |
      | 1       | A           | 2             | 0.16            |
      | 2       | B           | 1             | 0.08            |
    When I am logged in
    And I am have parked my car using real-time scheme
    And I am on my active parking page
    And I click on end parking
    Then I am moved to page where I see all my unpaid parkings

# Sprint 5
Feature: Pay for all unpaid parkings
  As a user
  Such that I have been using monthly payment scheme
  I want to pay for unpaid parkings

  Scenario: Pay for all unpaid parkings
    Given the following parking space
      | id | longitude       | latitude        | status      | user_id    | zone_id     |
      | 1  | 24.77177        | 59.43894        | Booked      | null       | 2           |
    And the following registred user
      | id  | name              | username | password | role      | credit_card_number | account_balance | valid_date | cvv | email                     | monthly_payment      |
      | 1   | Fred Flintstone   | Fred     | 123456   | customer  | 378734493671000    | 5000             | 09/20     | 123 | fred.flintstone@gmail.com | false                |
    And the following parking zones
      | id      | zone_type   | hourly_rate   | real_time_rate  |
      | 1       | A           | 2             | 0.16            |
      | 2       | B           | 1             | 0.08            |
    And the following allocation
      | id    | start_time           | end_time             | is_hourly  | price  | user_id | space_id | allocation_status |
      | 1     | 2019-12-02 21:12:04  | 2019-12-02 22:12:04  | false      | 22     | 1       | 1        | Unpaid            |
      | 2     | 2019-12-03 23:12:04  | 2019-12-03 23:56:04  | false      | 22     | 1       | 1        | Unpaid            |
    When I am logged in
    And I have previously activated monthly payment
    And I have previously been parking my car using real-time payment while monthly scheme was activated
    Then I should have table of unpaid parkings
    When I click on pay for all unpaid parkings
    Then parkings get paid and dissapear from unpaid parkings table




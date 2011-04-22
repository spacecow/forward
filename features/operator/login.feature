Feature:

Scenario: Correct login
When I go to the login page
And I fill in "Username" with "user"
And I fill in "Password" with "correct"
And I press "Log in"
Then I should be on to the edit page
And I should see "Successfully logged in." as notice flash message

Scenario: Incorrect login
When I go to the login page
And I fill in "Username" with "user"
And I fill in "Password" with "incorrect"
And I press "Log in"
Then I should be on to the login page
And I should see "Username or password incorrect." as alert flash message

Scenario: Cannot reach edit page without authorization
When I go to the edit page
Then I should be on the login page
And I should see "Unauthorized access." as alert flash message

Scenario: Logout
Given I am logged in as "test"
And I follow "Log out"
Then I should be on the login page
And I should see "Successfully logged out." as notice flash message

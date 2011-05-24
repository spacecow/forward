Feature:

Scenario: Correct login
When I go to the login page
And I fill in "Username" with "user"
And I fill in "Password" with "correct"
And I press "Login"
Then I should be on to the edit page
And I should see "Successfully logged in." as notice flash message

Scenario: Incorrect login
When I go to the login page
And I fill in "Username" with "user"
And I fill in "Password" with "incorrect"
And I press "Login"
Then I should be on to the login page
And I should see "Username or password incorrect." as alert flash message

Scenario: Cannot reach edit page without authorization
When I go to the edit page
Then I should be on the login page
And I should see "Unauthorized access." as alert flash message

Scenario: Logout
Given I am logged in as "test"
And I follow "Logout"
Then I should be on the login page
And I should see "Successfully logged out." as notice flash message

Scenario: Japanese view
When I go to the login page
And I follow "日本語"
Then the "ユーザー名" field should be empty
And the "パスワード" field should be empty
And I should see "English" within the "site nav" section

Scenario: English view
When I go to the login page
And I follow "日本語"
And I follow "English"
Then the "Username" field should be empty
And the "Password" field should be empty
And I should see "日本語" within the "site nav" section

@blank
Scenario: Blank login field is not acceptable
When I go to the login page
Then show me the page
And I press "Login"

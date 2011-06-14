Feature:
Background:
Given a user exists with email: "test@example.com", password: "secret"

Scenario: Log in
Given I go to the admin_login page
And I fill in "Email" with "test@example.com"
And I fill in "Password" with "secret"
And I press "Login"
And I should be on the translations page

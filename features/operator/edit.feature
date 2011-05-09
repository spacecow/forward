Feature:

Scenario: No access to edit without login
When I go to the edit page
Then I should see "Unauthorized access." as alert flash message
And I should be on the login page

Scenario: Edit forward file
And I am logged in as "test"
And I fill in "Forwarding address" with "test@example.com"
And I check "Keep a copy"
And I press "Update"

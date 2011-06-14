Feature:
Background:
Given I am logged in as admin

Scenario: Locale form view
When I go to the translations page
Then the "Title" field should be empty
And I should see a "Create Locale" button

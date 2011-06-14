Feature:
Background:
Given I am logged in as admin

Scenario: Edit locale view
Given a pair exists with locale: "en", key: "welcome", value: "Welcome!"
And a locale exists with title: "en"
When I go to the translations page
And I follow "Edit Locale" for key "en.welcome"
Then the "Title" field should contain "en"


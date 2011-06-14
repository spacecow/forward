Feature:
Background:
Given I am logged in as admin

Scenario: Edit a locale
Given a pair exists with locale: "en", key: "welcome", value: "Welcome!"
And a locale exists with title: "en"
When I go to the translations page
And I follow "Edit Locale" for key "en.welcome"
And I fill in "Title" with "en.label"
And I press "Update Locale"
Then a locale should exist with title: "en.label"
And 1 locales should exist
And I should see "Successfully updated locale." as notice flash message
And I should be on the translations page

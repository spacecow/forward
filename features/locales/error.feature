Feature:
Background:
Given I am logged in as admin

Scenario: Locales cannot be created blank
When I go to the translations page
And I fill in "Title" with ""
And I press "Create Locale"
Then I should see a locale title error "can't be blank"

Scenario: Locales cannot be updated blank
Given a pair exists with locale: "en", key: "welcome", value: "Welcome!"
And a locale exists with title: "en"
When I go to the translations page
And I follow "Edit Locale" for key "en.welcome"
And I fill in "Title" with ""
And I press "Update Locale"
Then I should see a locale title error "can't be blank"

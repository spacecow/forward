Feature:

Scenario: Edit a translation
Given a pair exists with locale: "en", key: "welcome", value: "Welcome!"
And a locale exists with title: "en"
When I go to the translations page
And I follow "Edit" for key "en.welcome"
Then the "Key" field should contain "welcome"
And the "Value" field should contain "Welcome!"

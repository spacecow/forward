Feature:

Scenario: Translations listing view
Given a pair exists with locale: "en", key: "welcome", value: "Welcome!"
When I go to the translations page
Then I should see /en\.welcome: "Welcome!"/

Scenario: New translation form view
When I go to the translations page
Then nothing should be selected in the "Locale" field
And the "Key" field should be empty
And the "Value" field should be empty

Scenario: Locales can be chosen with a drop down menu
Given a locale exists with title: "en"
When I go to the translations page
Then the "Locale" field should have options "BLANK, en"

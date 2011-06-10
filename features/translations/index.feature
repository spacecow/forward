Feature:

Scenario: New translation form view
When I go to the translations page
Then nothing should be selected in the "Locale" field
And the "Key" field should be empty
And the "Value" field should be empty

Scenario: Locales can be chosen with a drop down menu
Given a locale exists with title: "en"
When I go to the translations page
Then the "Locale" field should have options "BLANK, en"

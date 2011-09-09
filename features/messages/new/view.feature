Feature:
Background:
Given I am logged in as "test"
When I go to the new message page

Scenario: New Message View
Then the "Subject" field should be empty
And the "Message" field should be empty
And nothing should be selected in the "Priority" field
And the "Priority" field should have options "BLANK, low, normal, high, urgent"
And nothing should be selected in the "Type" field
And the "Type" field should have options "BLANK, bug, enhancement, feature, comment"
And the "Sender" field should contain "test"

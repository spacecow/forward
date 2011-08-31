Feature:

Scenario: Procmail Rule View
Given I am logged in as "test"
When I go to the new procmail filter page
Then the first "section" field should have options "BLANK, Subject, From, To, Cc"
And the first "part" field should have options "BLANK, contains, is, begins with, ends with"
And the first "substance" field should be empty
And I should see a "+" button within the "filter" form

Scenario: Procmail Action View
Given I am logged in as "test"
When I go to the new procmail filter page
Then the first "operation" field should have options "BLANK, Move Message to, Copy Message to, Forward Message to, Forward Copy to"
And the first "destination" field should be empty

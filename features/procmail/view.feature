Feature:

Scenario: Procmail Rule View
Given I am logged in as "test"
When I go to the new procmail filter page
Then the "filter_rules_attributes_0_section" field should have options "BLANK, Subject, From, Body, Date, To, Cc, To or Cc, X-Spam-level"
And the "filter_rules_attributes_0_part" field should have options "BLANK, contains, doesn't contain, is, isn't, begins with, ends with"
And the "filter_rules_attributes_0_substance" field should be empty
And I should see a "+" button within the "new_filter" form
And I should see a "-" button within the "new_filter" form

Scenario: Procmail Action View
Given I am logged in as "test"
When I go to the new procmail filter page
Then the "filter_actions_attributes_0_operation" field should have options "BLANK, Move Message to, Copy Message to, Forward Message to"
And the "filter_actions_attributes_0_destination" field should be empty

Feature:
Background:
Given I am logged in as "test"
And a filter exists
And a rule exists with filter: that filter, section: "Subject", part: "contains", substance: "yeah"
When I go to the procmail filter's edit page

Scenario: Edit filter view
And "Subject" should be selected in the first "rules section" field for "filter"
And "contains" should be selected in the first "rules part" field for "filter"
And the "filter_rules_attributes_0_substance" field should contain "yeah"

Scenario: Edit a filter
When I select "To" from "filter_rules_attributes_0_section"
And I press "Update"
Then a rule should exist with filter: that filter, section: "To", part: "contains", substance: "yeah"

Scenario: Add a rule
When I press "+" in the first "rules" listing for "filter"
Then show me the page
Then I should be on the procmail filter's edit page
And "Subject" should be selected in the first "rules section" field for "filter"
And nothing should be selected in the second "rules section" field for "filter"

Scenario: Delete a rule
When I press "-" in the first "rules" listing for "filter"

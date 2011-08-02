Feature:
Background:
Given a user exists with username: "test", password: "correct"
And I am logged in as that user
And a filter exists with user: that user
And an action exists with filter: that filter, operation: "Move Message to", destination: "temp"
And a rule exists with filter: that filter, section: "Subject", part: "contains", substance: "yeah"
When I go to the procmail filter's edit page

Scenario: Edit action view
Then "Move Message to" should be selected in the first "actions operation" field for "filter"
And the "filter_actions_attributes_0_destination" field should contain "temp"

Scenario: Edit an action
When I select "Copy Message to" from "filter_actions_attributes_0_operation"
And I press "Update"
Then an action should exist with filter: that filter, operation: "Copy Message to", destination: "temp"

Scenario: Empty actions are not saved
When I press "+" in the first "actions" listing for "filter"
And I select "Copy Message to" from "filter_actions_attributes_1_operation"
And I press "Update"
Then 1 actions should exist

Scenario: Add an action
When I press "+" in the first "actions" listing for "filter"
Then I should be on the procmail filter's edit page
And "Move Message to" should be selected in the first "actions operation" field for "filter"
And nothing should be selected in the second "actions operation" field for "filter"
And 1 actions should exist

Scenario: Add a second rule
When I press "+" in the first "actions" listing for "filter"
And I press "+" in the second "actions" listing for "filter"
Then "Move Message to" should be selected in the first "actions operation" field for "filter"
And nothing should be selected in the second "actions operation" field for "filter"
And nothing should be selected in the third "actions operation" field for "filter"
And 1 actions should exist

Scenario: An added actions' contents should remain when adding an additional action
When I press "+" in the first "actions" listing for "filter"
And I select "Copy Message to" from "filter_actions_attributes_1_operation"
And I press "+" in the second "actions" listing for "filter"
Then "Move Message to" should be selected in the first "actions operation" field for "filter"
And "Copy Message to" should be selected in the second "actions operation" field for "filter"
And nothing should be selected in the third "actions operation" field for "filter"

Scenario: An added rule's content should remain when adding an action
When I press "+" in the first "rules" listing for "filter"
And I select "begins with" from "filter_rules_attributes_1_part"
And I press "+" in the first "actions" listing for "filter"
Then "begins with" should be selected in the second "rules part" field for "filter"

Scenario: Delete an action
When I press "-" in the first "actions" listing for "filter"

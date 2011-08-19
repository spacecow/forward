Feature:
Background:
Given a user exists with username: "test", password: "correct"
And I am logged in as that user
And an action exists with operation: "Move Message to", destination: "temp"
And a rule exists with section: "Subject", part: "contains", substance: "yeah"
And a filter exists with user: that user, rules: that rule, actions: that action
When I go to the procmail filter's edit page

Scenario: Edit action view
Then "Move Message to" should be selected in the first "operation" field
And the first "destination" field should contain "temp"

Scenario: Edit an action
When I fill in the first "destination" field with "temporary"
And I press "Update"
Then 1 filters should exist
And an action should exist with filter: that filter, operation: "Move Message to", destination: "temporary"
And a file ".procmail" should exist with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR

:0:
*^Subject:.*yeah
.temporary/

"""

@wip
Scenario: Actions not fully filled in will not be saved, but other changes will
When I press "+" in the first "actions" listing for "filter"
And I fill in the first "destination" field with "temporary"
And I select "Copy Message to" from the second "operation" field
And I press "Update"
Then 1 actions should exist
And I should be on the procmail filters page
And I should see "Updated 1 rule & 1 action"

Scenario: Add an action
When I press "+" in the first "actions" listing for "filter"
Then "Move Message to" should be selected in the first "operation" field
And nothing should be selected in the second "operation" field
But I should see no third "operation" field
And the first "substance" field should contain "yeah"
And I should see no second "substance" field
And 1 actions should exist

Scenario: The one action cannot miss destination
When I fill in the first "destination" field with ""
And I press "Update"
And I should see an error "can't be blank" at the first "destination" field
But I should see no second "actions" listing
And I should see 1 "rules" listing

Scenario: The one action cannot miss operation
When I select "" from the first "operation" field
And I press "Update"
And I should see an error "can't be blank" at the first "operation" field
But I should see no second "actions" listing
And I should see 1 "rules" listing

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

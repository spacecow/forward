Feature:
Background:
Given a user exists with username: "test", password: "correct"
And I am logged in as that user
And a rule exists with section: "Subject", part: "contains", substance: "yeah"
And an action exists with operation: "move_message_to", destination: "temp"
And a filter exists with user: that user, rules: that rule, actions: that action
When I go to the procmail filter's edit page

Scenario: Edit action view
Then "Move Message to" should be selected in the first "operation" field
And the first "destination" field should contain "temp"

Scenario: Edit an action
When I fill in the first "destination" field with "temporary"
And I press "Update"
Then 1 filters should exist
And an action should exist with filter: that filter, operation: "move_message_to", destination: "temporary"
And a file ".procmail" should exist with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR

:0:
*^Subject:.*yeah
.temporary/

"""

Scenario: Actions not fully filled in will not be saved, but other changes will
When I press "+" in the first "actions" listing for "filter"
And I fill in the first "destination" field with "temporary"
And I select "Copy Message to" from the second "operation" field
And I press "Update"
Then a filter should exist
And an action should exist with filter: that filter, operation: "move_message_to", destination: "temporary"
And 1 actions should exist
And I should be on the procmail filters page
And I should see "Updated rules: 1, actions: 1"

Scenario: Add an action
When I press "+" in the first "actions" listing for "filter"
Then "Move Message to" should be selected in the first "operation" field
And nothing should be selected in the second "operation" field
But I should see no third "actions" listing
And the first "substance" field should contain "yeah"
And I should see no second "rules" listing
And 1 actions should exist

Scenario: Add a second action
When I press "+" in the first "actions" listing for "filter"
And I press "+" in the second "actions" listing for "filter"
Then "Move Message to" should be selected in the first "operation" field
And nothing should be selected in the second "operation" field
And nothing should be selected in the third "operation" field
And I should see no fourth "actions" listing
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

Scenario: An added actions' contents should remain when adding an additional action
When I press "+" in the first "actions" listing for "filter"
And I select "Copy Message to" from the second "operation" field
And I press "+" in the second "actions" listing for "filter"
Then "Move Message to" should be selected in the first "operation" field
And "Copy Message to" should be selected in the second "operation" field
And nothing should be selected in the third "operation" field
And I should see no fourth "actions" listing

Scenario: An added rule's content should remain when adding an action
When I press "+" in the first "rules" listing for "filter"
And I select "begins with" from the second "part" field
And I press "+" in the first "actions" listing for "filter"
Then "begins with" should be selected in the second "part" field

Scenario Outline: Delete an action
Given an action exists with operation: "copy_message_to", destination: "die", filter: that filter
When I go to the procmail filter's edit page
And I check the <order> "Remove Action"
And I press "Update"
Then an action should exist with destination: "<substance>"
And 1 actions should exist
And 1 rules should exist
Examples:
| order  | substance |
| first  | die       |
| second | temp      |

Scenario: If one deletes the last action, the filter is also deleted
When I check the first "Remove Action"
And I press "Update"
Then 0 filters should exist
And 0 rules should exist
And 0 actions should exist
And I should see "Successfully removed filter." as notice flash message
And a file ".procmail" should exist with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR



"""

Scenario: One cannot delete and leave a single empty action
When I press "+" in the first "actions" listing for "filter"
And I check the first "Remove Action"
And I press "Update"
And I should see an error "can't be blank" at the second "operation" field
And I should see an error "can't be blank" at the second "destination" field

Scenario: Add an extra action
When I fill in a second action
And I press "Update"
Then 2 actions should exist

Scenario: Delete an action that has not yet been saved
When I fill in a second action
And I check the second "Remove Action"
And I press "Update"
Then 1 actions should exist

Feature:
Background:
Given a user exists with username: "test", password: "correct"
And I am logged in as that user
And a rule exists with section: "subject", part: "contains", substance: "yeah"
And an action exists with operation: "move_message_to", destination: "temp"
And a filter exists with user: that user, rules: that rule, actions: that action
When I go to the procmail filter's edit page

Scenario: Edit rule view
Then "Subject" should be selected in the first "section" field
And "contains" should be selected in the first "part" field

Scenario: Edit a rule
When I select "To" from the first "section" field
And I press "Update"
Then 1 filters should exist
Then a rule should exist with filter: that filter, section: "To", part: "contains", substance: "yeah"
And a file ".procmailrc" should exist with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR
SHELL=/bin/sh

:0:
*^To:.*yeah
.temp/

"""

Scenario: Rules not fully filled in will not be saved, but other changes will
When I press "Add Rule"
And I fill in the first "substance" field with "oh yeah"
And I select "To" from the second "section" field
And I press "Update"
Then a filter should exist
And a rule should exist with filter: that filter, section: "Subject", part: "contains", substance: "oh yeah"
And 1 rules should exist
And I should be on the procmail filters page
And I should see "Updated rules: 1, actions: 1"

Scenario: Add a rule
When I press "Add Rule"
Then the first rule should be filled out
But the second rule should be empty
And I should see no third "rules" listing
And the first action should be filled out
But I should see no second "actions" listing
And 1 rules should exist

Scenario: Add a second rule
When I press "Add Rule"
And I press "Add Rule"
Then the first rule should be filled out
But the second rule should be empty
And the third rule should be empty
And I should see no fourth "rules" listing
And 1 rules should exist

Scenario: The one rule cannot miss section
When I select "" from the first "section" field
And I press "Update"
And I should see an error "can't be blank" at the first "section" field
But I should see no second "rules" listing
And I should see 1 "actions" listing

Scenario: The one rule cannot miss part
When I select "" from the first "part" field
And I press "Update"
And I should see an error "can't be blank" at the first "part" field
But I should see no second "rules" listing
And I should see 1 "actions" listing

Scenario: The one rule cannot miss substance
When I fill in the first "substance" field with ""
And I press "Update"
And I should see an error "can't be blank" at the first "substance" field
But I should see no second "rules" listing
And I should see 1 "actions" listing

Scenario: An added rule's contents should remain when adding an additional action
When I press "Add Rule"
And I select "is" from the second "part" field
And I press "Add Rule"
Then the first rule should be filled out
And "is" should be selected in the second "part" field
And the third rule should be empty

Scenario: An added actions' content should remain when adding a rule
When I press "Add Action"
And I select "Copy Message to" from the second "operation" field
And I press "Add Rule"
Then the first action should be filled out
And "Copy Message to" should be selected in the second "operation" field

Scenario Outline: Delete a rule 
Given a rule exists with section: "to", part: "is", substance: "SPAM", filter: that filter
When I go to the procmail filter's edit page
And I press the <order> "Delete" button
Then the first "substance" field should contain "<substance>"
And 1 rules should exist
Examples:
| order  | substance |
| first  | SPAM      |
| second | yeah      |

Scenario: Delete an added rule
When I go to the procmail filter's edit page
And I press "Add Rule"
And I press the second "Delete" button
Then the first "substance" field should contain "yeah"
And I should see no second "rules" listing

Scenario: If one deletes the last rule, a new empty rule appears
When I press the first "Delete" button
Then the first rule should be empty

Scenario: One cannot delete and leave a single empty rule
When I press "Add Rule"
And I press the first "Delete" button
And I press "Update"
And I should see an error "can't be blank" at the first "section" field
And I should see an error "can't be blank" at the first "part" field
And I should see an error "can't be blank" at the first "substance" field

Scenario: Add an extra rule
When I fill in a second rule
And I press "Update"
Then 2 rules should exist

Scenario: Delete a rule that has not yet been saved
When I fill in a second rule
And I press the second "Delete" button
And I press "Update"
Then 1 rules should exist

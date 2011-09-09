Feature:
Background:
Given a user exists with username: "test", password: "correct"
And I am logged in as that user
And a file ".procmail" exists with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR
"""

Scenario: New Filter Actions View
When I go to the new procmail filter page
Then nothing should be selected in the first "operation" field
And the first "destination" field should be empty
But I should see no second "destination" field

Scenario: A filter is not created if action is not completed
When I go to the new procmail filter page
And I fill in a rule
And I press "Create"
Then I should see an error "can't be blank" at the first "operation" field
And I should see no second "actions" listing
And I should see 1 "rules" listing 
And 0 filters should exist
And 0 actions should exist
And 0 rules should exist

Scenario: An action is only halfway done
When I go to the new procmail filter page
And I fill in the first "destination" field with "ohboy"
And I press "Create"
Then the first "substance" field should be empty
But I should see no second "rules" listing
And the first "destination" field should contain "ohboy"
But I should see no second "actions" listing

Scenario: Add an action before creating one
When I go to the new procmail filter page
And I press "Add Action"
Then I should see 1 "rules" listing
And I should see 2 "actions" listing

Scenario: A second action is not saved if it is not filled in correctly
When I go to the new procmail filter page
And I press "Add Action"
And I fill in a filter
And I fill in the second "destination" field with "it's ok"
And I press "Create"
Then 1 rules should exist
And 1 actions should exist
And I should see "Created rules: 1, actions: 1"

Scenario: Create a filter with two actions
When I go to the new procmail filter page
And I fill in a filter
And I fill in a second action
And I press "Create"
Then 2 actions should exist

Scenario: Delete an action that has not yet been saved
When I go to the new procmail filter page
And I fill in a filter
And I fill in a second action
And I check the second "Remove Action"
And I press "Create"
Then 1 actions should exist

Scenario: One cannot create a filter with every action removed 
When I go to the new procmail filter page
And I fill in a filter
And I check the first "Remove Action"
And I press "Create"
Then I should see "At least one action must exist."
And the first rule should be filled out
And the first action should be empty

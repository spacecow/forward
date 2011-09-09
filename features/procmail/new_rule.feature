Feature:
Background:
Given a user exists with username: "test", password: "correct"
And I am logged in as that user
And a file ".procmailrc" exists with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR
"""

Scenario: New Filter Rules View
When I go to the new procmail filter page
Then nothing should be selected in the first "section" field
And nothing should be selected in the first "part" field
And the first "substance" field should be empty
But I should see no second "substance" field

Scenario: A filter is not created if rule is not completed
When I go to the new procmail filter page
And I fill in an action
And I press "Create"
Then I should see an error "can't be blank" at the first "section" field
And I should see an error "can't be blank" at the first "part" field
And I should see an error "can't be blank" at the first "substance" field
And I should see no second "rules" listing
And I should see 1 "actions" listing
And 0 filters should exist
And 0 actions should exist
And 0 rules should exist

Scenario: A rule is only halfway done
When I go to the new procmail filter page
And I fill in the first "substance" field with "oh boy"
And I press "Create"
Then the first "substance" field should contain "oh boy"
But I should see no second "rules" listing
And the first "destination" field should be empty
But I should see no second "actions" listing

Scenario: Add a rule before creating one
When I go to the new procmail filter page
And I press "Add Rule"
Then I should see 2 "rules" listing
And I should see 1 "actions" listing

Scenario: A second rule is not saved if it is not filled in correctly
When I go to the new procmail filter page
And I press "Add Rule"
And I fill in a filter
And I fill in the second "substance" field with "it's ok"
And I press "Create"
Then 1 rules should exist
And 1 actions should exist
And I should see "Created rules: 1, actions: 1"

Scenario: Create a filter with two actions
When I go to the new procmail filter page
And I fill in a filter
And I fill in a second rule
And I press "Create"
Then 2 rules should exist

Scenario: Delete a rule that has not yet been saved
When I go to the new procmail filter page
And I fill in a filter
And I fill in a second action
And I press "Create"
Then 1 rules should exist

Scenario: One cannot create a filter with every rule removed 
When I go to the new procmail filter page
And I fill in a filter
And I check the first "Remove Rule"
And I press "Create"
Then I should see "At least one rule must exist."
And the first rule should be empty
And the first action should be filled out

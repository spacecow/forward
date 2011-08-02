Feature:
Background:
Given I am logged in as "test"
And a file ".procmail" exists with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR
"""
When I go to the new procmail filter page

Scenario: New Filter Rules View
Then nothing should be selected in the first "rules section" field for "filter"
And nothing should be selected in the first "rules part" field for "filter"
And the first "rules substance" field for "filter" should be empty
But I should see no second "rules substance" field for "filter"

Scenario: New Filter Actions View
Then nothing should be selected in the first "actions operation" field for "filter"
And the first "actions destination" field for "filter" should be empty
But I should see no second "actions destination" field for "filter"

Scenario: New Filter View
Then I should see a "Create" button
And I should see a "Cancel" button

Scenario: Cancel a creation
When I press "Cancel"
Then I should be on the procmail filters page
And 0 filters should exist

@wip
Scenario: A filter is not created if action is not completed
When I select "Subject" from the first "rules section" field for "filter"
And I select "contains" from the first "rules part" field for "filter"
And I fill in the first "rules substance" with "yeah"

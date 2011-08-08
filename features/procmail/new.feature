Feature:
Background:
Given a user exists with username: "test", password: "correct"
And I am logged in as that user
And a file ".procmail" exists with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR
"""

Scenario: New Filter Rules View
When I go to the new procmail filter page
Then nothing should be selected in the first "rules section" field for "filter"
And nothing should be selected in the first "rules part" field for "filter"
And the first "rules substance" field for "filter" should be empty
But I should see no second "rules substance" field for "filter"

Scenario: New Filter Actions View
When I go to the new procmail filter page
Then nothing should be selected in the first "actions operation" field for "filter"
And the first "actions destination" field for "filter" should be empty
But I should see no second "actions destination" field for "filter"

Scenario: New Filter View
When I go to the new procmail filter page
Then I should see a "Create" button
And I should see a "Cancel" button

Scenario: Cancel a creation
When I go to the new procmail filter page
And I press "Cancel"
Then I should be on the procmail filters page
And 0 filters should exist

Scenario: A filter is not created if action is not completed
When I go to the new procmail filter page
And I select "Subject" from the first "rules section" field for "filter"
And I select "contains" from the first "rules part" field for "filter"
And I fill in the first "rules substance" field with "yeah" for "filter"
And I press "Create"
Then I should see "At least one action must exist."
And 0 filters should exist
And 0 actions should exist
And 0 rules should exist

@wip
Scenario: A rule is only halfway done
When I go to the new procmail filter page
And I fill in the first "rules substance" field with "oh boy" for "filter"
And I press "Create"
Then the first "rules substance" field should contain "oh boy" for "filter"

Scenario: A filter is not created if rule is not completed
When I go to the new procmail filter page
And I select "Move Message to" from the first "actions operation" field for "filter"
And I fill in the first "actions destination" field with "temp" for "filter"
And I press "Create"
Then I should see "At least one rule must exist."
And 0 filters should exist
And 0 actions should exist
And 0 rules should exist

Scenario: Create a filter
When I go to the new procmail filter page
And I select "Subject" from the first "rules section" field for "filter"
And I select "contains" from the first "rules part" field for "filter"
And I fill in the first "rules substance" field with "yeah" for "filter"
And I select "Move Message to" from the first "actions operation" field for "filter"
And I fill in the first "actions destination" field with "temp" for "filter"
And I press "Create"
Then 1 filters should exist
And a rule should exist with filter: that filter, section: "Subject", part: "contains", substance: "yeah"
And an action exist with filter: that filter, operation: "Move Message to", destination: "temp"
And a file ".procmail" should exist with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR

:0:
*^Subject:.*yeah
.temp/

"""

Scenario: Create a second filter
Given an action exists with operation: "Move Message to", destination: "temp"
And a rule exists with section: "Subject", part: "contains", substance: "yeah"
And a filter exists with user: that user, rules: that rule, actions: that action
When I go to the new procmail filter page
And I select "To" from the first "rules section" field for "filter"
And I select "is" from the first "rules part" field for "filter"
And I fill in the first "rules substance" field with "oh boy" for "filter"
And I select "Forward Copy to" from the first "actions operation" field for "filter"
And I fill in the first "actions destination" field with "example@gmail.com" for "filter"
And I press "Create"
Then 2 filters should exist
And a file ".procmail" should exist with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR

:0:
*^Subject:.*yeah
.temp/

:0c
*^To: oh boy$
!example@gmail.com

"""

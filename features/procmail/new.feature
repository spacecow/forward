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
Then nothing should be selected in the first "section" field
And nothing should be selected in the first "part" field
And the first "substance" field should be empty
But I should see no second "substance" field

Scenario: New Filter Actions View
When I go to the new procmail filter page
Then nothing should be selected in the first "operation" field
And the first "destination" field should be empty
But I should see no second "destination" field

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
And I select "Subject" from the first "section" field
And I select "contains" from the first "part" field
And I fill in the first "substance" field with "yeah"
And I press "Create"
Then I should see "At least one action must exist."
And 0 filters should exist
And 0 actions should exist
And 0 rules should exist

Scenario: A rule is only halfway done
When I go to the new procmail filter page
And I fill in the first "substance" field with "oh boy"
And I press "Create"
Then the first "substance" field should contain "oh boy"
But I should see no second "substance" field
And the first "destination" field should be empty
But I should see no second "destination" field

Scenario: An action is only halfway done
When I go to the new procmail filter page
And I fill in the first "destination" field with "ohboy"
And I press "Create"
Then the first "substance" field should be empty
But I should see no second "substance" field
And the first "destination" field should contain "ohboy"
But I should see no second "destination" field

Scenario: Add a rule before creating one
When I go to the new procmail filter page
And I press "+" in the first "rules" listing for "filter"
Then the second "substance" field should be empty
But I should see no third "substance" field
And the first "destination" field should be empty
But I should see no second "destination" field

Scenario: Add an action before creating one
When I go to the new procmail filter page
And I press "+" in the first "actions" listing for "filter"
Then the first "substance" field should be empty
But I should see no second "substance" field
And the second "destination" field should be empty
But I should see no third "destination" field

Scenario: A filter is not created if rule is not completed
When I go to the new procmail filter page
And I select "Move Message to" from the first "operation" field
And I fill in the first "destination" field with "temp"
And I press "Create"
Then I should see "At least one rule must exist."
And 0 filters should exist
And 0 actions should exist
And 0 rules should exist

Scenario: Create a filter
When I go to the new procmail filter page
And I select "Subject" from the first "section" field
And I select "contains" from the first "part" field
And I fill in the first "substance" field with "yeah"
And I select "Move Message to" from the first "operation" field
And I fill in the first "destination" field with "temp"
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
And I select "To" from the first "section" field
And I select "is" from the first "part" field
And I fill in the first "substance" field with "oh boy"
And I select "Forward Copy to" from the first "operation" field
And I fill in the first "destination" field with "example@gmail.com"
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

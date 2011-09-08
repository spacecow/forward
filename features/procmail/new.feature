Feature:
Background:
Given a user exists with username: "test", password: "correct"
And I am logged in as that user
And a file ".procmail" exists with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR
"""

Scenario: New Filter View
When I go to the new procmail filter page
Then I should see a "Create" button
And I should see a "Cancel" button

Scenario: Cancel a creation
When I go to the new procmail filter page
And I fill in a filter
And I press "Cancel"
Then 0 filters should exist

Scenario: Create a filter
When I go to the new procmail filter page
And I fill in a filter
And I press "Create"
Then 1 filters should exist
And a rule should exist with filter: that filter, section: "Subject", part: "contains", substance: "yeah"
And an action exist with filter: that filter, operation: "move_message_to", destination: "temp"
And I should see "Successfully created filter." as notice flash message
And a file ".procmail" should exist with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR

:0:
*^Subject:.*yeah
.temp/

"""

Scenario: Create a second filter
Given an action exists with operation: "forward_copy_to", destination: "example@gmail.com"
And a rule exists with section: "to", part: "is", substance: "oh boy"
And a filter exists with user: that user, rules: that rule, actions: that action
When I go to the new procmail filter page
And I fill in a filter
And I press "Create"
Then 2 filters should exist
And a file ".procmail" should exist with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR

:0c
*^To: oh boy$
!example@gmail.com

:0:
*^Subject:.*yeah
.temp/

"""

Scenario: One cannot create a filter with every action&rules removed 
When I go to the new procmail filter page
And I check the first "Remove Action"
And I check the first "Remove Rule"
And I press "Create"
Then I should see "At least one action must exist."
And I should see "At least one rule must exist."
And the first rule should be empty
And the first action should be empty

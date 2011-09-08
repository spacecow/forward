Feature:
Background:
Given a user exists with username: "test", password: "correct"
And I am logged in as that user
And a file ".procmail" exists with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR

:0
*^Subject:.*yeah
.temp/
"""
When I go to the procmail filters page
Then 1 filters should exist
When I go to the procmail filter's edit page

Scenario: You should be able to log out
Then show me the page
When I follow "Logout"
Then I should be on the login page

Scenario: Cancel an edit
When I fill in the first "destination" field with "temporary"
And I press "Cancel"
Then 1 filters should exist
And an action should exist with filter: that filter, operation: "move_message_to", destination: "temp"


Feature:
Background:
Given a user exists with username: "test", password: "correct"
And I am logged in as that user
And a file ".procmailrc" exists with:
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
And a file ".procmailrc" should exist with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR

:0:
*^Subject:.*yeah
.temp/

"""

Scenario: Creation of a filter should add a line to .forward
Given a file ".forward" exists with:
"""
"""
When I go to the new procmail filter page
And I fill in a filter
And I press "Create"
Then a file ".forward" should exist with:
"""
"|IFS=' ' && exec /usr/local/bin/procmail -f- || exit 75 #test"

"""

Scenario: Nothing is written to .forward if it is already set up for procmail
Given a file ".forward" exists with:
"""
"|IFS=' ' && exec /usr/local/bin/procmail -f- || exit 75 #test"

"""
When I go to the new procmail filter page
And I fill in a filter
And I press "Create"
Then a file ".forward" should exist with:
"""
"|IFS=' ' && exec /usr/local/bin/procmail -f- || exit 75 #test"

"""

Scenario: Create a second filter
Given an action exists with operation: "forward_copy_to", destination: "example@gmail.com"
And a rule exists with section: "to", part: "is", substance: "oh boy"
And a filter exists with user: that user, rules: that rule, actions: that action
When I go to the new procmail filter page
And I fill in a filter
And I press "Create"
Then 2 filters should exist
And a file ".procmailrc" should exist with:
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

Scenario: A long file should also be saved
Given a file ".procmailrc" exists with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR

:0c:
*^Subject:.*fefe
.fefwwdx/

:0:
*^From:.*fefe
.fefe/

:0:
*^Cc:.*d$
./

:0:
*^Subject:.*fefe
.fefe/
"""
When I go to the procmail filters page
And I go to the new procmail filter page
And I fill in a filter
And I press "Create"
Then a file ".procmailrc" should exist with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR

:0c:
*^Subject:.*fefe
.fefwwdx/

:0:
*^From:.*fefe
.fefe/

:0:
*^Cc:.*d$
./

:0:
*^Subject:.*fefe
.fefe/

:0:
*^Subject:.*yeah
.temp/

"""

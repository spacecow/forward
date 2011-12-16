Feature:

Scenario: Save a filter without a .procmailrc
Given I am logged in as "test"
And a file ".procmailrc" exists with:
"""
"""
When I go to the procmail filters page
And I go to the new procmail filter page
And I fill in a filter
And I press "Create"
Then a file ".procmailrc" should exist with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR
SHELL=/bin/sh

:0:
*^Subject:.*yeah
.temp/

"""

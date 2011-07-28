Feature:
Background:
Given I am logged in as "test"

Scenario: Filter index view
Given a file ".procmail" with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR

:0 :
*^From:.*root@riec.*
.root/

:0 :
*^To:.*admin-ml*^@.*riec.*
.admin-ml/
"""
When I go to the procmail filters page
Then I should see "^From:*root@riec.*"

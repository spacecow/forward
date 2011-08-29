Feature:
Background:
Given I am logged in as "test"

Scenario: Two filters 
Given a file ".procmailrc" exists with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR

:0 :
*^From: root@riec$
.root/

:0 :
*^To:.*admin-ml.*@.*riec.*
.admin-ml/
"""
When I go to the procmail filters page
Then I should see the following filters:
| From | is       | root@riec         | Move Message to | root     |
| To   | contains | admin-ml.*@.*riec | Move Message to | admin-ml |
And a filter should exist
And a rule should exist with filter: that filter, section: "From", part: "is", substance: "root@riec"
And an action should exist with filter: that filter, operation: "Move Message to", destination: "root"

Scenario: A filter has two rules
Given a file ".procmailrc" exists with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR

:0c
*^From: root@riec$
*^Subject: secret
!test@gmail.com
"""
When I go to the procmail filters page
Then I should see the following filters:
| From    | is          | root@riec | Forward Copy to | test@gmail.com |
| Subject | begins with | secret    |                 |                |
And a filter should exist
And a rule should exist with filter: that filter, section: "From", part: "is", substance: "root@riec"
And a rule should exist with filter: that filter, section: "Subject", part: "begins with", substance: "secret"
And an action should exist with filter: that filter, operation: "Forward Copy to", destination: "test@gmail.com"

Scenario: A filter has two actions
Given a file ".procmailrc" exists with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR

:0
*^To:.*test@example.com$
{
  :0:
  .temporary/

  :0c
  !testier@example.com
}
"""
When I go to the procmail filters page
Then I should see the following filters:
| To | ends with | test@example.com | Move Message to | temporary           |
|    |           |                  | Forward Copy to | testier@example.com |
And a filter should exist
And a rule should exist with filter: that filter, section: "To", part: "ends with", substance: "test@example.com"
And an action should exist with filter: that filter, operation: "Forward Copy to", destination: "testier@example.com"
And an action should exist with filter: that filter, operation: "Move Message to", destination: "temporary"

Scenario: Links on filter index page
When I go to the procmail filters page
Then I should see links "New Filter" at the bottom of the page

Scenario: Links from filter index page
When I go to the procmail filters page
And I follow "New Filter" at the bottom of the page
Then I should be on the new procmail filter page

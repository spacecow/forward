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
| 1. | If from is "root@riec",             | then move message to "root".     | Edit |
| 2. | If to contains "admin-ml.*@.*riec", | then move message to "admin-ml". | Edit |
And a filter should exist
And a rule should exist with filter: that filter, section: "From", part: "is", substance: "root@riec"
And an action should exist with filter: that filter, operation: "move_message_to", destination: "root"

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
| 1. | If from is "root@riec",          | then forward copy to "test@gmail.com". | Edit |
|    | If subject begins with "secret", |                                        |      |
And a filter should exist
And a rule should exist with filter: that filter, section: "From", part: "is", substance: "root@riec"
And a rule should exist with filter: that filter, section: "Subject", part: "begins_with", substance: "secret"
And an action should exist with filter: that filter, operation: "forward_copy_to", destination: "test@gmail.com"

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
| 1. | If to ends with "test@example.com", | then move message to "temporary".           | Edit |
|    |                                     | then forward copy to "testier@example.com". |      |
And a filter should exist
And a rule should exist with filter: that filter, section: "To", part: "ends_with", substance: "test@example.com"
And an action should exist with filter: that filter, operation: "forward_copy_to", destination: "testier@example.com"
And an action should exist with filter: that filter, operation: "move_message_to", destination: "temporary"

Scenario: Links on filter index page
When I go to the procmail filters page
Then I should see links "New Mail Filter" at the bottom of the page

Scenario: Links from filter index page
When I go to the procmail filters page
And I follow "New Mail Filter" at the bottom of the page
Then I should be on the new procmail filter page

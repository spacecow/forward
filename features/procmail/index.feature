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
| 1. | If From is "root@riec",             | then Move Message to "root".     | Edit | Del |
| 2. | If To contains "admin-ml.*@.*riec", | then Move Message to "admin-ml". | Edit | Del |
And a filter should exist
And a rule should exist with filter: that filter, section: "From", part: "is", substance: "root@riec"
And an action should exist with filter: that filter, operation: "move_message_to", destination: "root"

Scenario: A filter has three AND-rules
Given a file ".procmailrc" exists with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR

:0c
*^From: root@riec$
*^Subject: secret
*^To:.*user
!test@gmail.com
"""
When I go to the procmail filters page
Then I should see the following filters:
| 1. | If From is "root@riec"           | then Forward Copy to "test@gmail.com". | Edit | Del |
|    | and Subject begins with "secret" |                                        |      |     |
|    | and To contains "user",          |                                        |      |     |
And a filter should exist
And a rule should exist with filter: that filter, section: "From", part: "is", substance: "root@riec"
And a rule should exist with filter: that filter, section: "Subject", part: "begins_with", substance: "secret"
And an action should exist with filter: that filter, operation: "forward_copy_to", destination: "test@gmail.com"

Scenario: A filter has three OR-rules
Given a file ".procmailrc" exists with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR

:0c
*^From:(root@riec$|.*secret.*|SPAM)
!test@gmail.com
"""
When I go to the procmail filters page
Then I should see the following filters:
| 1. | If From is "root@riec"      | then Forward Copy to "test@gmail.com". | Edit | Del |
|    | or From contains "secret"   |                                        |      |     |
|    | or From begins with "SPAM", |                                        |      |     |
And a filter should exist with glue: "or"
And 1 filters should exist
And a rule should exist with filter: that filter, section: "From", part: "is", substance: "root@riec"
And a rule should exist with filter: that filter, section: "From", part: "contains", substance: "secret"
And a rule should exist with filter: that filter, section: "From", part: "begins_with", substance: "SPAM"
And 3 rules should exist
And an action should exist with filter: that filter, operation: "forward_copy_to", destination: "test@gmail.com"
And 1 actions should exist

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
| 1. | If To ends with "test@example.com", | then Move Message to "temporary".           | Edit | Del |
|    |                                     | then Forward Copy to "testier@example.com". |      |     |
And a filter should exist
And a rule should exist with filter: that filter, section: "To", part: "ends_with", substance: "test@example.com"
And an action should exist with filter: that filter, operation: "forward_copy_to", destination: "testier@example.com"
And an action should exist with filter: that filter, operation: "move_message_to", destination: "temporary"

Scenario: Links on filter index page
When I go to the procmail filters page
Then I should see links "New Mail Filter" at the bottom of the page

Scenario Outline: Links from filter index page
When I go to the procmail filters page
And I follow "<link>" at the <section> of the page
Then I should be on the <path> page
Examples:
| link                 | path                | section |
| New Mail Filter      | new procmail filter | bottom  |
| Flexible Information | new message         | footer  |

Scenario: Delete a filter
Given a file ".procmailrc" exists with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR

:0 :
*^From: root@riec$
.root/
"""
When I go to the procmail filters page
And I follow "Del" within the first "filters" table row
Then 0 filters should exist
And 0 rules should exist
And 0 actions should exist

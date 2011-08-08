Feature:
Background:
Given I am logged in as "test"
And a file ".procmail" exists with:
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

Scenario: Filter index view
Then show me the page
Then I should see "^From: root@riec$" within the first "filters" table row
And I should see ".root/" within the first "filters" table row
And I should see an "Edit" link within the first "filters" table row
And I should see "^To:.*admin-ml.*@.*riec" within the second "filters" table row
And I should see ".admin-ml/" within the second "filters" table row
And I should see links "New Filter" at the bottom of the page

Scenario: Save and create filter models
Then 2 filters should exist
And a rule should exist with section: "From", part: "is", substance: "root@riec"
And a rule should exist with section: "To", part: "contains", substance: "admin-ml.*@.*riec"

Scenario: Links from filter index page
When I follow "New Filter" at the bottom of the page
Then I should be on the new procmail filter page

Feature:
Background:
Given a user exists with username: "test", password: "correct"
And I am logged in as that user
And a rule exists with section: "Subject", part: "contains", substance: "yeah"
And an action exists with operation: "Move Message to", destination: "temp"
And a filter exists with user: that user, rules: that rule, actions: that action
When I go to the procmail filter's edit page

Scenario: Edit rule view
Then "Subject" should be selected in the first "rules section" field for "filter"
And "contains" should be selected in the first "rules part" field for "filter"
And the first "rules substance" field should contain "yeah" for "filter"

Scenario: Edit a rule
When I select "To" from the first "rules section" field for "filter"
And I press "Update"
Then 1 filters should exist
Then a rule should exist with filter: that filter, section: "To", part: "contains", substance: "yeah"
And a file ".procmail" should exist with:
"""
MAILDIR=$HOME/Maildir/
DEFAULT=$MAILDIR

:0 :
*^To:.*yeah
.temp/

"""

Scenario: Empty rules are not saved
When I press "+" in the first "rules" listing for "filter"
And I select "To" from the first "rules section" field for "filter"
And I select "ends with" from the first "rules part" field for "filter"
And I press "Update"
Then 1 rules should exist

Scenario: Add a rule
When I press "+" in the first "rules" listing for "filter"
Then I should be on the procmail filter's edit page
And "Subject" should be selected in the first "rules section" field for "filter"
And nothing should be selected in the second "rules section" field for "filter"
And 1 rules should exist

Scenario: Add a second rule
When I press "+" in the first "rules" listing for "filter"
And I press "+" in the first "rules" listing for "filter"
Then "Subject" should be selected in the first "rules section" field for "filter"
And nothing should be selected in the second "rules section" field for "filter"
And nothing should be selected in the third "rules section" field for "filter"
And 1 rules should exist

Scenario: An added rule's contents should remain when adding an additional action
When I press "+" in the first "rules" listing for "filter"
And I select "is" from the second "rules part" field for "filter"
And I press "+" in the second "rules" listing for "filter"
Then "Subject" should be selected in the first "rules section" field for "filter"
And "is" should be selected in the second "rules part" field for "filter"
And nothing should be selected in the third "rules part" field for "filter"

Scenario: An added actions' content should remain when adding a rule
When I press "+" in the first "actions" listing for "filter"
And I select "Copy Message to" from the second "actions operation" field for "filter"
And I press "+" in the first "rules" listing for "filter"
Then "Copy Message to" should be selected in the second "actions operation" field for "filter"

Scenario: Delete a rule
When I press "-" in the first "rules" listing for "filter"

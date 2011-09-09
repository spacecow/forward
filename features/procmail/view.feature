Feature:

Scenario: Index view
Given I am logged in as "test"
When I go to the procmail filters page
Then the menu "Mail-filtering" should be active
And I should see "Mail Filter Settings for test" as title

Scenario: Procmail Rule View
Given I am logged in as "test"
When I go to the new procmail filter page
Then the first "section" field should have options "BLANK, Subject, From, To, Cc, To or Cc, Spam-Flag"
And the first "part" field should have options "BLANK, contains, is, begins with, ends with"
And the first "substance" field should be empty
And I should see an "Add Rule" button within the "filter" form
And the menu "Mail-filtering" should be active

Scenario: Procmail Action View
Given I am logged in as "test"
When I go to the new procmail filter page
Then the first "operation" field should have options "BLANK, Move Message to, Copy Message to, Forward Message to, Forward Copy to"
And the first "destination" field should be empty
And I should see an "Add Action" button within the "filter" form
And the menu "Mail-filtering" should be active

Scenario Outline: Links on the Procmail Index Page for admin
Given I am logged in as admin
Then I should see links "Mail-forwarding, Mail-filtering, Translations" within the "navigation" section
When I go to the procmail filters page
And I follow "<link>"
Then I should be on the <section> page
Examples:
| link            | section          |
| Mail-forwarding | forward edit     |
| Mail-filtering  | procmail filters |
| Translations    | translations     |

Scenario Outline: Links on the Procmail Index Page for user
Given I am logged in as "test"
Then I should see links "Mail-forwarding, Mail-filtering" within the "navigation" section
When I go to the procmail filters page
And I follow "<link>"
Then I should be on the <section> page
Examples:
| link            | section          |
| Mail-forwarding | forward edit     |
| Mail-filtering  | procmail filters |

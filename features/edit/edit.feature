Feature:

Scenario: Edit the sixth address
Given dotforward contains "test1\ntest2\ntest3\ntest4\ntest5\ntest6\n"
And I am logged in as "test"
When I fill in the sixth "Address" with "test6@example.com"
And I press "Update"
Then dotforward should contain "test1\ntest2\ntest3\ntest4\ntest5\ntest6@example.com\n"
And I should see 6 "Address" fields

Scenario: Keeping a copy on the server
Given dotforward contains "test1\n"
And I am logged in as "test"
When I check "Keep a copy on the server"
And I press "Update"
Then dotforward should contain "\test\ntest1\n"
And I should see 5 "Address" fields
And the "Keep a copy on the server" checkbox should be checked

Scenario: Add a field
Given dotforward contains "test1\n"
And I am logged in as "test"
And I press "Add Address Field"
Then I should see a "Address 6" field
But I should see "Successfully added address field." as notice flash message

@japanese
Scenario: Add a field in japanese
Given dotforward contains "test1\n"
And I am logged in as "test"
And I follow "日本語"
And I press "転送先を増やす"
Then I should see a "転送先 6" field
But I should see "転送先が追加されました" as notice flash message

Scenario: Add a field with the checkbox checked
Given dotforward contains "\test\ntest1\n"
And I am logged in as "test"
And I press "Add Address Field"
Then I should see a "Address 6" field

Scenario: Adding a field should not update other fields but should still show changes that were made
Given dotforward contains "test1\n"
And I am logged in as "test"
And I fill in the first "Address" with "test1@example.com"
And I check "Keep a copy on the server"
And I press "Add Address Field"
Then dotforward should contain "test1\n"
And the first "Address" field should contain "test1@example.com"
And the "Keep a copy on the server" checkbox should be checked

Scenario: Adding a field should still display changes that was made
Given dotforward contains "test1\n"
And I am logged in as "test"
And I fill in the first "Address" with "test1@example.com"
And I check "Keep a copy on the server"
And I press "Add Address Field"
Then dotforward should contain "test1\n"
And the first "Address" field should contain "test1@example.com"
And the "Keep a copy on the server" checkbox should be checked

Scenario: Adding a seventh field
Given dotforward contains "test1\ntest2\ntest3\ntest4\ntest5\ntest6\n"
And I am logged in as "test"
And I press "Add Address Field"
Then I should see 7 "Address" fields 

@japanese
Scenario: Added fields should stay when hitting the language link
Given dotforward contains "test1\n"
And I am logged in as "test"
When I press "Add Address Field"
And I follow "日本語"
Then I should see 6 "転送先" fields
And I should see fields from "転送先 1" to "転送先 6"
When I follow "English"
Then I should see 6 "Address" fields
And I should see fields from "Address 1" to "Address 6"

@japanese
Scenario: Changed text but not yet saved cannot stay when hitting the language link
Given dotforward contains "test1\n"
And I am logged in as "test"
When I fill in the first "Address" with "test1@example.com"
And I follow "日本語"
Then I should see 5 "転送先" fields
And the first "転送先" field should contain "test1"

@javascript
Scenario: Add a field on the fly
Given dotforward contains "test1\n"
And I am logged in as "test"
When I follow "Add Address Field"
Then I should see fields from "Address 1" to "Address 6"

@javascript
Scenario: Add two fields on the fly
Given dotforward contains "test1\n"
And I am logged in as "test"
When I follow "Add Address Field"
When I follow "Add Address Field"
Then I should see fields from "Address 1" to "Address 7"

Feature:

@edit
Scenario: Edit the sixth address
Given dotforward contains "test1\ntest2\ntest3\ntest4\ntest5\ntest6\n"
And I am logged in as "test"
And I fill in the sixth "Address" with "test6@example.com"
And I press "Update"
Then dotforward should contain "test1\ntest2\ntest3\ntest4\ntest5\ntest6@example.com\n"
And I should see 6 "Address" fields

Scenario: Add a field
Given dotforward contains "test1\n"
And I am logged in as "test"
And I press "Add address field"
Then I should see a sixth "Address" field
But I should see "Successfully added address field." as notice flash message

Scenario: Adding a field should not update other fields but should still show changes that were made
Given dotforward contains "test1\n"
And I am logged in as "test"
And I fill in the first "Address" with "test1@example.com"
And I check "Keep a copy on the server"
And I press "Add address field"
Then dotforward should contain "test1\n"
And the first "Address" field should contain "test1@example.com"
And the "Keep a copy on the server" checkbox should be checked

@pending
Scenario: Adding a field should still display changes that was made


Scenario: Adding a seventh field
Given dotforward contains "test1\ntest2\ntest3\ntest4\ntest5\ntest6\n"
And I am logged in as "test"
And I press "Add address field"
Then I should see 7 "Address" fields 

@pending
Scenario: Added fields should stay when hitting the language link

@pending
Scenario: Changed text but not yet saved should stay when hitting the language link

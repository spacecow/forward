Feature:

Scenario: No access to edit without login
When I go to the edit page
Then I should see "Unauthorized access." as alert flash message
And I should be on the login page

Scenario: Edit forward file
Given I am logged in as "test"
And I fill in "Address" with "test@example.com"
And I check "Keep a copy"
And I press "Update"

Scenario: Edit view in Japanese
Given I am logged in as "test"
When I follow "日本語"
Then I should see "ログアウト"
And I should see "転送先"
And I should see "サーバにメールを残す"
And I should see a "更新" button

Scenario: Edit view in English
Given dotforward contains "test1"
And I am logged in as "test"
Then I should see "Logout"
And I should see fields from "Address 1" to "Address 5"
And I should not see "Address 6"
And the "Keep a copy on the server" checkbox should not be checked
And I should see an "Update" button 
And I should see an "Add Address Field" button

Scenario: Keep a copy on the server is activated
Given dotforward contains "\test\ntest1"
And I am logged in as "test"
Then the first "Address" field should contain "test1"
And the second through fifth "Address" field should be empty
And I should see no sixth "Address" field
And the "Keep a copy on the server" checkbox should be checked

Scenario: View of one address
Given dotforward contains "test@example.com"
And I am logged in as "test"
Then the first "Address" field should contain "test@example.com"
And the second through fifth "Address" field should be empty

Scenario: View of six addresses
Given dotforward contains "test1\ntest2, test3\ntest4\ntest5\ntest6"
And I am logged in as "test"
Then the first "Address" field should contain "test1"
And the second "Address" field should contain "test2"
And the third "Address" field should contain "test3"
And the fourth "Address" field should contain "test4"
And the fifth "Address" field should contain "test5"
And the sixth "Address" field should contain "test6"
But I should see no seventh "Address" field

@javascript
Scenario: Edit view with javascript
Given dotforward contains "test1"
And I am logged in as "test"
Then I should see a "Add Address Field" button

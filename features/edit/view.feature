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
Given I am logged in as "test"
Then I should see "Logout"
And I should see "Address 1"
And I should see "Address 2"
And I should see "Address 3"
And I should see "Address 4"
And I should see "Address 5"
And I should not see "Address 6"
And I should see "Keep a copy on the server"
And I should see a "Update" button 

@read
Scenario: View of one address
Given dotforward contains "test@example.com"
And I am logged in as "test"
Then the first "Address" field should contain "test@example.com"

@read
Scenario: View of six addresses
Given dotforward contains "test1\ntest2\ntest3\ntest4\ntest5\ntest6"
And I am logged in as "test"
Then the first "Address" field should contain "test1"
And the second "Address" field should contain "test2"
And the third "Address" field should contain "test3"
And the fourth "Address" field should contain "test4"
And the fifth "Address" field should contain "test5"
And the sixth "Address" field should contain "test6"
But I should see no seventh "Address" field

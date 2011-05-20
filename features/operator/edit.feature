Feature:

Scenario: No access to edit without login
When I go to the edit page
Then I should see "Unauthorized access." as alert flash message
And I should be on the login page

Scenario: Edit forward file
Given I am logged in as "test"
And I fill in "Forwarding address" with "test@example.com"
And I check "Keep a copy"
And I press "Update"

Scenario: Edit view in Japanese
Given I am logged in as "test"
When I follow "日本語"
Then I should see "ログアウト"
And I should see "転送先"
And I should see "サーバにメールを残す"
And I should see a button "更新"

Scenario: Edit view in English
Given I am logged in as "test"
Then I should see "Logout"
And I should see "Forwarding address"
And I should see "Keep a copy on the server"
And I should see a button "Update"

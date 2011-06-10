Feature:

Scenario: Key must be filled in
When I go to the translations page
And I fill in "Key" with ""
And I press "Create"
Then I should see a translation key error "can't be blank"

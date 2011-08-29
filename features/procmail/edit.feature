Feature:
Background:
Given a user exists with username: "test", password: "correct"
And I am logged in as that user
And an action exists
And a rule exists
And a filter exists with user: that user, rules: that rule, actions: that action
When I go to the procmail filter's edit page

Scenario: You should be able to log out
When I follow "Logout"

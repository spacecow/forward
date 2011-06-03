Feature:

@edit
Scenario: Edit the sixth address
Given dotforward contains "test1\ntest2\ntest3\ntest4\ntest5\ntest6\n"
And I am logged in as "test"
And I fill in the sixth "Address" with "test6@example.com"
And I press "Update"
Then dotforward should contain "test1\ntest2\ntest3\ntest4\ntest5\ntest6@example.com\n"

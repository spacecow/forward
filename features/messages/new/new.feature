Feature:
Background:
Given a user exists with username: "test", password: "correct"
Given I am logged in as that user
When I go to the new message page

Scenario: Message validation
When I press "Send Message"
Then I should see a "Subject" error "can't be blank"
And I should see a "Message" error "can't be blank"
And I should see a "Priority" error "can't be blank"
And I should see a "Type" error "can't be blank"

Scenario: Send a message
When I fill in "Subject" with "A subject"
And I fill in "Message" with "A message"
And I select "urgent" from "Priority"
And I select "bug" from "Type"
And I press "Send Message"
Then a message should exist with subject: "A subject", body: "A message", priority: "urgent", message_type: "bug", user: that user
And 1 messages should exist
And I should see "Thank you. Your message has been sent." as notice flash message
And 1 email should be delivered to jsveholm@fir.riec.tohoku.ac.jp 

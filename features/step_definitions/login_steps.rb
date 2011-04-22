Given /^I am logged in as "([^"]*)"$/ do |user|
  Given %(I go to the login page)
  And %(I fill in "Username" with "#{user}")
  And %(I fill in "Password" with "correct")
  And %(I press "Log in")
end

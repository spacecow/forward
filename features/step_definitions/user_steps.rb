Given /^I am logged in as admin$/ do
  Given %(I go to the login page)
  And %(a user exists with username: "admin", password: "correct")
  And %(that user is an admin)
  And %(I fill in "Username" with "admin")
  And %(I fill in "Password" with "correct")
  And %(I press "Login")
end

Given /^#{capture_model} is an admin$/ do |mdl|
  user = model(mdl)
  user.roles_mask = 2
  user.save
end

Given /^I am logged in as #{capture_model}$/ do |mdl|
  Given %(I am logged in as "#{model(mdl).username}")
end

Given /^I am logged in as "([^"]*)"$/ do |user|
  Given %(I go to the login page)
  #And %(a user exists with username: "#{user}", password: "correct")
  And %(I fill in "Username" with "#{user}")
  And %(I fill in "Password" with "correct")
  And %(I press "Login")
end

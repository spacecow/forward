Given /^I am logged in as admin$/ do
  Given %(I go to the admin_login page)
  And %(a user exists with email: "test@example.com", password: "secret")
  And %(I fill in "Email" with "test@example.com")
  And %(I fill in "Password" with "secret")
  And %(I press "Login")
end

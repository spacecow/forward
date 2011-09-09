Given /^a file "([^"]*)" exists with:$/ do |file,txt|
  File.open("/usr/local/sbin/#{file}", "w") do |file|
    file.write(txt)
  end
end

Then /^a file "([^"]*)" should exist with:$/ do |file,txt|
  File.open("/usr/local/sbin/#{file}", "r") do |file|
    file.readlines.join.should == txt
  end
end

When /I fill in a rule$/ do
  When %(I select "Subject" from the first "section" field)
  And %(I select "contains" from the first "part" field)
  And %(I fill in the first "substance" field with "yeah")
end
When /I fill in a second rule$/ do
  When %(I press "Add Rule")
  When %(I select "To" from the second "section" field)
  And %(I select "is" from the second "part" field)
  And %(I fill in the second "substance" field with "oh boy")
end


When /I fill in an action/ do
  When %(I select "Move Message to" from the first "operation" field)
  And %(I fill in the first "destination" field with "temp")
end
When /I fill in a second action/ do
  When %(I press "Add Action")
  And %(I select "Copy Message to" from the second "operation" field)
  And %(I fill in the second "destination" field with "temporary")
end

When /I fill in a filter/ do
  When %(I fill in a rule)
  And %(I fill in an action)
end

Then /the first rule should be filled out/ do
  Then %("Subject" should be selected in the first "section" field)
  And %("contains" should be selected in the first "part" field)
  And %(the first "substance" field should contain "yeah")
end
Then /the (\w+) rule should be empty/ do |ordr|
  Then %(nothing should be selected in the #{ordr} "section" field)
  And %(nothing should be selected in the #{ordr} "part" field)
  And %(the #{ordr} "substance" field should be empty)
end

Then /the first action should be filled out/ do
  Then %("Move Message to" should be selected in the first "operation" field)
  And %(the first "destination" field should contain "temp")
end
Then /the (\w+) action should be empty/ do |ordr|
  Then %(nothing should be selected in the #{ordr} "operation" field)
  And %(the #{ordr} "destination" field should be empty)
end

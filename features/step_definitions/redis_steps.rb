Given /^a pair exists with locale: "([^"]*)", key: "([^"]*)", value: "([^"]*)"$/ do |locale,key,val|
  I18n.backend.store_translations(locale, {key => val}, :escape => false)
end

When /^I delete key "([^"]*)"$/ do |txt|
  find(:css, "li", :text => txt).click_link("Del")
end

Then /^a pair should exists with key: "([^"]*)", value: "([^"]*)"$/ do |key,val|
  $redis[key].should eq "\"#{val}\""
end

Then /^the key "([^"]*)" should not exist$/ do |key|
  $redis[key].should be_nil
end


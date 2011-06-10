Given /^a pair exists with locale: "([^"]*)", key: "([^"]*)", value: "([^"]*)"$/ do |locale,key,val|
  I18n.backend.store_translations(locale, {key => val}, :escape => false)
end

Then /^a pair should exists with key: "([^"]*)", value: "([^"]*)"$/ do |key,val|
  $redis[key].should eq "\"#{val}\""
end

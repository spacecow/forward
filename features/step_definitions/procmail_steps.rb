Given /^a file "([^"]*)" exists with:$/ do |file,txt|
  File.open("/usr/local/sbin/.procmailrc", "w") do |file|
    file.write(txt)
  end
end

Given /^a file "([^"]*)" should exist with:$/ do |file,txt|
  File.open("/usr/local/sbin/.procmailrc", "r") do |file|
    file.readlines.join.should == txt
  end
end

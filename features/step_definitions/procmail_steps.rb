Given /^a file "([^"]*)" with:$/ do |file,txt|
  File.open("/usr/local/sbin/.procmailrc", "w") do |file|
    file.write(txt)
  end
end

#Then /^dotforward should contain "([^"]*)"$/ do |lines|
#  File.open("/usr/local/sbin/.forward", "r") do |file|
#    file.readlines.join.should eq lines.gsub('\\n',"\n")
#  end
#end

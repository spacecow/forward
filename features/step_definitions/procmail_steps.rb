Given /^a file "([^"]*)" exists with:$/ do |file,txt|
  File.open("/usr/local/sbin/.procmailrc", "w") do |file|
    file.write(txt)
  end
end

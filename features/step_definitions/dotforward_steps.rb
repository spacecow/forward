Given /^dotforward contains "([^"]*)"$/ do |lines|
  file = File.open("/usr/local/sbin/.forward", "w")
  file.write("#{lines}\n")
  file.close
end

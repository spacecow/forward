Given /^dotforward contains "([^"]*)"$/ do |lines|
  File.open("/usr/local/sbin/.forward", "w") do |file|
    lines.split('\\n').each do |line|
      file.write("#{line}\n")
    end
  end
end

Then /^dotforward should contain "([^"]*)"$/ do |lines|
  File.open("/usr/local/sbin/.forward", "r") do |file|
    file.readlines.join.should eq lines.gsub('\\n',"\n")
  end
end

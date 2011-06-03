Given /^dotforward contains "([^"]*)"$/ do |lines|
  file = File.open("/usr/local/sbin/.forward", "w")
  lines.split('\\n').each do |line|
    file.write("#{line}\n")
  end
  file.close
end

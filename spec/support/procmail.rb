def load_procmailrc(s)
  File.open("/usr/local/sbin/.procmailrc","w") do |f|
    f.write s
  end
end

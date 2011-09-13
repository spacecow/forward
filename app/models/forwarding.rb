module Forwarding
  def load_forwards(username, password)
    IO.popen("/usr/local/sbin/chfwd -g #{username}", 'r+') do |pipe|
      pipe.write(password)
      pipe.close_write
      pipe.read
    end
  end

  def save_forwards(arr, username, password)
    IO.popen("/usr/local/sbin/chfwd -s #{username}", 'r+') do |pipe|
      pipe.write "#{password}\n"
      pipe.write "#{arr.join("\n")}\n"
      pipe.close_write
    end
  end

  def update_forwards(username, password)
    s = load_forwards(username, password)
    unless s.include?("/usr/local/bin/procmail")
      arr = s.split("\n")
      arr.push(%("|IFS=' ' && exec /usr/local/bin/procmail -f- || exit 75 ##{username}"))
      save_forwards(arr, username, password)
    end
  end

  def convert_in(s)
    ret = {} 
    adds = s.split("\n").map{|line| line.split(',').map(&:strip)}.flatten
    keep = nil
    adds.each_with_index do |add,i|
      keep = adds.delete_at(i) if add[0] == "\\"
    end
    adds.each_with_index do |add,i|
      ret[i.to_s] = add.chomp
    end
    (5-adds.length).times do |i|
      ret[(i+adds.length).to_s] = ""
    end
    ret[:keep] = !keep.nil?
    ret
  end
end

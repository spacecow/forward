module Forward
  def convert_in(s)
    ret = []
    adds = s.split("\n").map{|line| line.split(',').map(&:strip)}.flatten
    keep = nil
    adds.each_with_index do |add,i|
      keep = adds.delete_at(i) if add[0] == "\\"
    end
    adds.each do |add|
      ret << {:address => add.chomp}
    end
    (5-ret.size).times do |add|
      ret << {:address => nil}
    end
    ret << {:keep => !keep.nil?}
  end
end

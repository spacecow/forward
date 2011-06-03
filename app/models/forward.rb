module Forward
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

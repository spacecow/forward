module Forward
  def convert_in(arr)
    arr.map{|e| {:address => e.chomp}}
  end
end

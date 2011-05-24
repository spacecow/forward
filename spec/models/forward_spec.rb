require 'spec_helper' 

class Bajs 
  include Forward
end

describe Forward do
  before(:each){ @bajs = Bajs.new }
  it "should handle one address" do
    @bajs.convert_in("test1@example.com\n").should eq return_arr(["test1@example.com"])
  end

  it "should handle two addresses" do
    @bajs.convert_in("test1@example.com\ntest2@example.com\n").should eq return_arr %w(test1@example.com test2@example.com)
  end 
 
  it "should handle a mail forward" do
    @bajs.convert_in("\\testuser\n").should eq return_arr([],true)
  end

  it "should handle addresses and mail forward" do
    @bajs.convert_in("\\testuser\ntest1@example.com\n").should eq return_arr(%w(test1@example.com),true)
  end 

  it "should handle addresses and mail forward in wrong order" do
    @bajs.convert_in("test2@example.com\n\\testuser\ntest1@example.com\n").should eq return_arr(%w(test2@example.com test1@example.com),true)
  end 
end

def return_arr(a,b=false)
  ret = []
  a.each{|s| ret << {:address => s}}
  (5-a.length).times{ret << {:address => nil}}
  ret << {:keep => b}
end

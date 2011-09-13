require 'spec_helper' 

class Bajs 
  include Forwarding
end

describe Forwarding do
  before(:each){ @bajs = Bajs.new }

  it "should handle an empty file" do
    @bajs.convert_in("").should eq return_arr []
  end

  it "should handle one address" do
    @bajs.convert_in("test1@example.com\n").should eq return_arr(["test1@example.com"])
  end

  it "should handle two addresses" do
    @bajs.convert_in("test1@example.com\ntest2@example.com\n").should eq return_arr %w(test1@example.com test2@example.com)
  end 
 
  it "should handle addresses with extra spaces" do
    @bajs.convert_in("   test1@example.com\ntest2@example.com   \n").should eq return_arr %w(test1@example.com test2@example.com)
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

  it "should handle a comma-separated line" do
    @bajs.convert_in("test1@example.com,test2@example.com").should eq return_arr %w(test1@example.com test2@example.com)
  end

  it "should handle a comma-separated line with extra spaces" do
   @bajs.convert_in("   test1@example.com  ,  test2@example.com").should eq return_arr %w(test1@example.com test2@example.com)
  end

  it "should except more than 5 addresses" do
    @bajs.convert_in("test1, test2, test3, test4, test5, test6").should eq return_arr %w(test1 test2 test3 test4 test5 test6)
  end

  it "should handle a mix of everyhing" do
    @bajs.convert_in("test1, test2, \\user\ntest3, test4, test5, test6").should eq return_arr(%w(test1 test2 test3 test4 test5 test6),true)
  end
end

def return_arr(a,b=false)
  ret = {} 
  a.each_with_index{|s,i| ret[i.to_s] = s}
  (5-a.length).times{|i| ret[(i+a.length).to_s] = ""}
  ret[:keep] = b
  ret
end

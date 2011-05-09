require 'spec_helper' 

class Bajs 
  include Forward
end

describe Forward do
  before(:each){ @bajs = Bajs.new }
  it "should handle one address" do
    @bajs.convert_in(["test1@example.com"]).should eq [{:address => "test1@example.com"}]
  end

  it "should handle two addresses" do
    @bajs.convert_in(["test1@example.com\n", "test2@example.com\n"]).should eq [{:address => "test1@example.com"},{:address => "test2@example.com"}]
  end 
end

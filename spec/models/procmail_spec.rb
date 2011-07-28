require 'spec_helper' 

class Bajs 
  include Procmail
end

describe Procmail do
  before(:each){ @bajs = Bajs.new }

  context "#load_rule" do
    it "basj" do
      @bajs.load_rule("*^To:.*admin-ml*^@.*riec.*")
    end
  end
end

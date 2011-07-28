require 'spec_helper' 

class Bajs 
  include Procmail
end

describe Procmail do
  before(:each){ @bajs = Bajs.new }

  context "#load_rule" do
    before(:each){ @filter = Filter.new }
    context "split up a rule where the splitter is" do
      it ":.*" do @bajs.load_rule("*^To:.*admin-ml*^@.*riec.*", @filter) end
      it ".*" do @bajs.load_rule("*^To.*admin-ml*^@.*riec.*", @filter) end

      after(:each) do
        @filter.rules.last.section.should == "To"
        @filter.rules.last.substance.should == "admin-ml*^@.*riec.*"
      end
    end
  end
end

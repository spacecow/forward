require 'spec_helper' 

class Bajs 
  include Procmail
end

describe Procmail do
  before(:each){ @bajs = Bajs.new }

  context "#load_action" do
    before(:each){ @filter = Filter.new }

    it "splits up in operation and " do
    end
  end

  context "#load_rule" do
    before(:each){ @filter = Filter.new }

    it "splits up in section, substance and part" do
      @bajs.load_rule("*^To:.*admin-ml*^@.*riec.*", @filter)
      @filter.rules.last.section.should == "To"
      @filter.rules.last.substance.should == "admin-ml*^@.*riec"
      @filter.rules.last.part.should == "contains"
    end

    context "split up a rule where the splitter is" do
      it ":.*" do @bajs.load_rule("*^To:.*admin-ml*^@.*riec.*", @filter) end
      it ".*" do @bajs.load_rule("*^To.*admin-ml*^@.*riec.*", @filter) end

      after(:each) do
        @filter.rules.last.section.should == "To"
        @filter.rules.last.substance.should == "admin-ml*^@.*riec"
      end
    end

    context "#load_part to" do
      it "contains" do
        @bajs.load_part(".*admin-ml*^@.*riec.*").should == "contains"
      end

      it "is" do
        @bajs.load_part("admin-ml*^@.*riec").should == "is"
      end

      it "begins with" do
        @bajs.load_part("admin-ml*^@.*riec.*").should == "begins with"
      end
        
      it "ends with" do
        @bajs.load_part(".*admin-ml*^@.*riec").should == "ends with"
      end
    end

    context "#strip_substance for part:" do
      it "contains" do
        @substance = @bajs.strip_substance(".*admin-ml*^@.*riec.*")
      end

      it "is" do
        @substance = @bajs.strip_substance("admin-ml*^@.*riec")
      end

      it "begins with" do
        @substance = @bajs.strip_substance("admin-ml*^@.*riec.*")
      end
        
      it "ends with" do
        @substance = @bajs.strip_substance(".*admin-ml*^@.*riec")
      end

      after(:each) do
        @substance.should == "admin-ml*^@.*riec"
      end
    end
  end
end

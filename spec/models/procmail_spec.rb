require 'spec_helper' 

class Bajs 
  include Procmail
end

describe Procmail do
  before(:each){ @bajs = Bajs.new }

  context "#save_filters", :wip => true do
    before(:each) do
      rule = Rule.create(:section => "Subject", :part => "contains", :substance => "yeah")
      action = Action.create(:operation => "Move Message to", :destination => "temp")
      @filter = Filter.create
      @filter.rules << rule
      @filter.actions << action
    end

    it "saves a users filter to file" do
      @bajs.save_filters("test", "correct", [@filter])
      @bajs.read_filters("test", "correct").first.contents.should == 
        [["Subject", "yeah", "contains"], ["Move Message to", ".temp/"]]
    end

    context "#rules_to_file" do
      it "has 1 lines for 1 rule" do
        @filter.rules_to_file.should eq "*^Subject:.*yeah"
      end
    end

    context "#actions_to_file" do
      it "has 1 lines for 1 action" do
        @filter.actions_to_file.should eq "temp"
      end
    end

    context "#to_file" do
      it "has 3 lines for 1 rule & 1 action" do
        @filter.to_file.should eq ":0 :\n*^Subject:.*yeah\ntemp"
      end
    end
  end

  context "#rules_to_s for part" do
    it "contains ending with star" do 
      arr = @bajs.load_filters(":0 :\n*^To:.*admin-ml*^@.*riec.*\n.admin-ml/")
      arr.first.rules_to_s.should == "^To:.*admin-ml*^@.*riec"
    end

    it "contains" do 
      arr = @bajs.load_filters(":0 :\n*^To:.*admin-ml*^@.*riec\n.admin-ml/")
      arr.first.rules_to_s.should == "^To:.*admin-ml*^@.*riec"
    end

    it "is" do 
      arr = @bajs.load_filters(":0 :\n*^To: admin-ml*^@.*riec$\n.admin-ml/")
      arr.first.rules_to_s.should == "^To: admin-ml*^@.*riec$"
    end

    it "begins with ending with star" do 
      arr = @bajs.load_filters(":0 :\n*^To: admin-ml*^@.*riec.*\n.admin-ml/")
      arr.first.rules_to_s.should == "^To: admin-ml*^@.*riec"
    end
 
    it "begins with" do 
      arr = @bajs.load_filters(":0 :\n*^To: admin-ml*^@.*riec\n.admin-ml/")
      arr.first.rules_to_s.should == "^To: admin-ml*^@.*riec"
    end

    it "ends with" do 
      arr = @bajs.load_filters(":0 :\n*^To:.*admin-ml*^@.*riec$\n.admin-ml/")
      arr.first.rules_to_s.should == "^To:.*admin-ml*^@.*riec$"
    end
  end
  
  context "#load_filters" do
    it "returns an empty array if file is empty" do
      arr = @bajs.load_filters("")
      arr.should be_empty
    end
      
    it "returns 1 filter in an array" do
      arr = @bajs.load_filters(":0 :\n*^To:.*admin-ml*^@.*riec.*\n.admin-ml/")
      arr.size.should == 1
      arr.last.contents.should == [["To", "admin-ml*^@.*riec", "contains"],
                                   ["Move Message to", ".admin-ml/"]]
    end

    it "returns 2 filters in an array" do
      arr = @bajs.load_filters(":0 :\n*^To:.*admin-ml*^@.*riec.*\n.admin-ml/\n\n:0 :\n*^CC:.*fir@.*riec.*\n.fir-cc/")
      arr.size.should == 2
      arr.first.contents.should == [["To", "admin-ml*^@.*riec", "contains"],
                                    ["Move Message to", ".admin-ml/"]]
      arr.last.contents.should == [["CC", "fir@.*riec", "contains"],
                                    ["Move Message to", ".fir-cc/"]]
    end
  end

  context "#load_filter" do
    it "splits up in rule and action" do
      filter = @bajs.load_filter(":0:","*^To:.*admin-ml*^@.*riec.*", ".admin-ml")
      filter.rules.last.contents.should == ["To", "admin-ml*^@.*riec", "contains"]
      filter.actions.last.contents.should == ["Move Message to", ".admin-ml/"]
    end 
  end
    
  context "#load_action", :load_action => true do
    before(:each){ @filter = Filter.new }

    context "creates a destination folrder with dot and slash for" do
      it "dot, non-slash" do @bajs.load_action(":0:","admin-ml", @filter) end
      it "non-dot, slash" do @bajs.load_action(":0:","admin-ml/", @filter) end
      it "non-dot, non-slash" do @bajs.load_action(":0:","admin-ml", @filter) end
      it "dot, slash" do @bajs.load_action(":0:",".admin-ml/", @filter) end
      
      after(:each) do
        @filter.actions.last.contents.should == ["Move Message to", ".admin-ml/"]
      end
    end

    context "Move Message to, for:" do
      it ":0" do @bajs.load_action(":0", ".admin-ml/", @filter) end
      it ":0:" do @bajs.load_action(":0", ".admin-ml/", @filter) end
      it ":0 :" do @bajs.load_action(":0", ".admin-ml/", @filter) end

      after(:each) do
        @filter.actions.last.contents.should == ["Move Message to", ".admin-ml/"]
      end
    end

    context "Copy Message to, for:" do
      it ":0c" do @bajs.load_action(":0c", ".admin-ml/", @filter) end
      it ":0c:" do @bajs.load_action(":0c", ".admin-ml/", @filter) end

      after(:each) do
        @filter.actions.last.contents.should == ["Copy Message to", ".admin-ml/"]
      end
    end

    context "Forward Message to, for:" do
      it "! x" do @bajs.load_action(":0", "! test@example.com", @filter) end
      it "!x" do @bajs.load_action(":0", "!test@example.com", @filter) end

      after(:each) do
        @filter.actions.last.contents.should == ["Forward Message to", "test@example.com"]
      end
    end    
  end

  context "#load_rule" do
    before(:each){ @filter = Filter.new }

    it "splits up in section, substance and part" do
      @bajs.load_rule("*^To:.*admin-ml*^@.*riec.*", @filter)
      @filter.rules.last.contents.should == ["To", "admin-ml*^@.*riec", "contains"]
    end

    context "split up a rule where the splitter is" do
      it ":.*" do @bajs.load_rule("*^To:.*admin-ml*^@.*riec.*", @filter) end
      it ".*" do @bajs.load_rule("*^To.*admin-ml*^@.*riec.*", @filter) end
      it ": " do @bajs.load_rule("*^To: admin-ml*^@.*riec.*", @filter) end

      after(:each) do
        @filter.rules.last.section.should == "To"
        @filter.rules.last.substance.should == "admin-ml*^@.*riec"
      end
    end

    context "#load_part to" do
      it "contains with star" do
        @bajs.load_part(".*admin-ml*^@.*riec.*").should == "contains"
      end
      it "contains" do
        @bajs.load_part(".*admin-ml*^@.*riec").should == "contains"
      end

      it "is" do
        @bajs.load_part("admin-ml*^@.*riec$").should == "is"
      end

      it "begins with, with star" do
        @bajs.load_part("admin-ml*^@.*riec.*").should == "begins with"
      end
      it "begins with" do
        @bajs.load_part("admin-ml*^@.*riec").should == "begins with"
      end
        
      it "ends with" do
        @bajs.load_part(".*admin-ml*^@.*riec$").should == "ends with"
      end
    end

    context "#strip_substance for part:" do
      it "contains with star" do
        @substance = @bajs.strip_substance(".*admin-ml*^@.*riec.*")
      end
      it "contains" do
        @substance = @bajs.strip_substance(".*admin-ml*^@.*riec")
      end

      it "is" do
        @substance = @bajs.strip_substance("admin-ml*^@.*riec$")
      end

      it "begins with, with star" do
        @substance = @bajs.strip_substance("admin-ml*^@.*riec.*")
      end
      it "begins with" do
        @substance = @bajs.strip_substance("admin-ml*^@.*riec")
      end
        
      it "ends with" do
        @substance = @bajs.strip_substance(".*admin-ml*^@.*riec$")
      end

      after(:each) do
        @substance.should == "admin-ml*^@.*riec"
      end
    end
  end
end

require 'spec_helper' 

class Bajs 
  include Procmail
end

describe Procmail do
  before(:each){ @bajs = Bajs.new }

  context "#read_filters", :read_filters => true do
    it "should raise an error when dealing with tags it does not know" do
      filter = ":0:\n*^Super-Strange-Tag:.*YES\n.Junk/"
      lambda{@bajs.load_filters(filter)}.should raise_error(KeywordException)
      
    end
    it "should handle spam" do
      filter = ":0:\n*^(X-Spam-Flag|X-Barracuda-Spam-Flag):.*YES\n.Junk/"
      lambda{@bajs.load_filters(filter)}.should_not raise_error(KeywordException)
    end
  end

  context "#save_filters", :save_filters => true do
    before(:each) do
      rule = Rule.create(:section => "subject", :part => "contains", :substance => "yeah")
      action = Action.create(:operation => "Move Message to", :destination => "temp")
      @filter = Filter.create
      @filter.rules << rule
      @filter.actions << action
      @filter.save
    end

    it "saves a users filter to file" do
      @bajs.save_filters("test", "correct", [@filter])
      @bajs.read_filters("test", "correct").first.contents.should == 
        [["subject", "yeah", "contains"], ["move_message_to", "temp"]]
    end

    context "#rules_to_file", :rules_to_file => true do
      it "has 1 lines for 1 rule" do
        @filter.rules_to_file.should eq "*^Subject:.*yeah"
      end

      it "has 2 lines for 2 rules" do
        @filter.rules << Rule.create(:section => "to", :part => "contains", :substance => "gmail")
        @filter.rules_to_file.should eq "*^Subject:.*yeah\n*^To:.*gmail"
      end
    end

    context "#to_file", :to_file => true do
      it "has a mark of copy in the recipe if copy" do
        @filter.actions.destroy_all
        @filter.actions << Action.create(:operation => "copy_message_to", :destination => "temp")
        @filter.to_file.should eq ":0c:\n*^Subject:.*yeah\n.temp/" 
      end

      it "does not need a lock if it is forwarding" do
        @filter.actions.destroy_all
        @filter.actions << Action.create(:operation => "forward_message_to", :destination => "example@gmail.com")
        @filter.to_file.should eq ":0\n*^Subject:.*yeah\n!example@gmail.com" 
      end

      it "has 3 lines for 1 rule & 1 action" do
        @filter.to_file.should eq ":0:\n*^Subject:.*yeah\n.temp/"
      end

      it "has 4 lines for 2 rules & 1 action" do
        @filter.rules << Rule.create(:section => "to", :part => "contains", :substance => "gmail")
        @filter.to_file.should eq ":0:\n*^Subject:.*yeah\n*^To:.*gmail\n.temp/"
      end

      it "has 10 lines for 2 rules & 2 actions" do
        @filter.rules << Rule.create(:section => "to", :part => "contains", :substance => "gmail")
        @filter.actions << Action.create(:operation => "forward_copy_to", :destination => "temp@gmail.com")
        @filter.to_file.should eq ":0\n*^Subject:.*yeah\n*^To:.*gmail\n{\n\t:0c\n\t!temp@gmail.com\n\n\t:0:\n\t.temp/\n}"
      end
    end
  end

  context "#actions_to_file", :actions_to_file => true do
    before(:each) do
      @filter = Filter.new
      @filter.rules << Factory.build(:rule)
    end

    it "has 1 line for 1 action" do
      @filter.actions << Action.create(:operation => "move_message_to", :destination => "temp")
      @filter.save
      @filter.actions_to_file.should eq ".temp/"
    end

    context "has 7 lines for 2 actions, for:" do
      it "move, move" do
        @filter.actions << Action.new(:operation => "move_message_to", :destination => "temp")
        @filter.actions << Action.new(:operation => "forward_message_to", :destination => "example@gmail.com")
        @filter.save
        @filter.actions_to_file.should eq "{\n\t:0c:\n\t.temp/\n\n\t:0\n\t!example@gmail.com\n}"
      end

      it "copy, move" do
        @filter.actions << Action.create(:operation => "copy_message_to", :destination => "temp")
        @filter.save
        @filter.actions << Action.create(:operation => "forward_message_to", :destination => "example@gmail.com")
        @filter.actions_to_file.should eq "{\n\t:0c:\n\t.temp/\n\n\t:0\n\t!example@gmail.com\n}"
      end
  
      it "move, copy" do
        @filter.actions << Action.create(:operation => "forward_message_to", :destination => "example@gmail.com")
        @filter.save
        @filter.actions << Action.create(:operation => "copy_message_to", :destination => "temp")
        @filter.actions_to_file.should eq "{\n\t:0c:\n\t.temp/\n\n\t:0\n\t!example@gmail.com\n}"
      end

      it "copy, copy" do
        @filter.actions << Action.create(:operation => "copy_message_to", :destination => "temp")
        @filter.save
        @filter.actions << Action.create(:operation => "forward_copy_to", :destination => "example@gmail.com")
        @filter.actions_to_file.should eq "{\n\t:0c:\n\t.temp/\n\n\t:0c\n\t!example@gmail.com\n}"
      end
  
    end
  end

  context "#rules_to_s for part", :rules_to_s => true do
    it "contains ending with star" do 
      arr = @bajs.load_filters(":0 :\n*^To:.*admin-ml*^@.*riec.*\n.admin-ml/")
      arr.first.rules_to_s.should == ["^To:.*admin-ml*^@.*riec"]
    end

    it "contains" do 
      arr = @bajs.load_filters(":0 :\n*^To:.*admin-ml*^@.*riec\n.admin-ml/")
      arr.first.rules_to_s.should == ["^To:.*admin-ml*^@.*riec"]
    end

    it "is" do 
      arr = @bajs.load_filters(":0 :\n*^To: admin-ml*^@.*riec$\n.admin-ml/")
      arr.first.rules_to_s.should == ["^To: admin-ml*^@.*riec$"]
    end

    it "begins with ending with star" do 
      arr = @bajs.load_filters(":0 :\n*^To: admin-ml*^@.*riec.*\n.admin-ml/")
      arr.first.rules_to_s.should == ["^To: admin-ml*^@.*riec"]
    end
 
    it "begins with" do 
      arr = @bajs.load_filters(":0 :\n*^To: admin-ml*^@.*riec\n.admin-ml/")
      arr.first.rules_to_s.should == ["^To: admin-ml*^@.*riec"]
    end

    it "ends with" do 
      arr = @bajs.load_filters(":0 :\n*^To:.*admin-ml*^@.*riec$\n.admin-ml/")
      arr.first.rules_to_s.should == ["^To:.*admin-ml*^@.*riec$"]
    end
  end
  
  context "#actions_to_s", :actions_to_s => true do
    before(:each) do
      rule = Factory.build(:rule)
      action = Action.create(:operation => "move_message_to", :destination => "temp")
      @filter = Filter.create
      @filter.rules << rule
      @filter.actions << action
    end

    it "has 1 line for 1 action" do
      @filter.actions_to_s.should eq ["temp"]
    end

    it "has 2 lines for 2 actions" do
      @filter.actions << Action.create(:operation => "forward_message_to", :destination => "example@gmail.com")
      @filter.actions_to_s.should eq ["temp", "example@gmail.com"]
    end
  end

  context "#load_filters", :load_filters => true do
    it "returns an empty array if file is empty" do
      arr = @bajs.load_filters("")
      arr.should be_empty
    end
      
    it "returns 1 filter in an array" do
      arr = @bajs.load_filters(":0 :\n*^To:.*admin-ml*^@.*riec.*\n.admin-ml/")
      arr.size.should == 1
      arr.last.contents.should == [["to", "admin-ml*^@.*riec", "contains"],
                                   ["move_message_to", "admin-ml"]]
    end

    it "returns 2 filters in an array" do
      arr = @bajs.load_filters(":0 :\n*^To:.*admin-ml*^@.*riec.*\n.admin-ml/\n\n:0 :\n*^Cc:.*fir@.*riec.*\n.fir-cc/")
      arr.size.should == 2
      arr.first.contents.should == [["to", "admin-ml*^@.*riec", "contains"],
                                    ["move_message_to", "admin-ml"]]
      arr.last.contents.should == [["cc", "fir@.*riec", "contains"],
                                    ["move_message_to", "fir-cc"]]
    end
  end

  context "#load_filter", :load_filter => true do
    it "splits up in rule and action" do
      p filter = @bajs.load_filter(":0:",["*^To:.*admin-ml*^@.*riec.*", ".admin-ml"])
      filter.rules.last.contents.should == ["to", "admin-ml*^@.*riec", "contains"]
      filter.actions.last.contents.should == ["move_message_to", "admin-ml"]
    end 

    it "can load two actions" do
      filter = @bajs.load_filter(":0", ["*^To: test@example.com", "{", "\t:0c:", "\t.temp/", "\n", "\t:0c:", "\t.temporary", "\}"])
      filter.rules_contents.should == [["to", "test@example.com", "begins_with"]]
      filter.actions_contents.should == [["copy_message_to", "temp"],["copy_message_to", "temporary"]]
    end
  end
    
  context "#load_action", :load_action => true do
    before(:each){ @filter = Filter.new }

    it "error gets raised if destination email is not valid" do
      lambda{@bajs.load_action(":0:", "!", @filter)}.should raise_error(InvalidEmailException)
    end

    it "destination email is valid", :resemble_email => true do
      lambda{@bajs.load_action(":0:", "!example@gmail.com", @filter)}.should_not raise_error(InvalidEmailException)
    end



    it "destination folder can be empty if a message is being moved" do
      @bajs.load_action(":0:", "./", @filter)
      @filter.actions.last.contents.should == ["move_message_to", ""]
    end

    context "creates a destination folder with dot and slash for" do
      it "dot, non-slash" do @bajs.load_action(":0:",".admin-ml", @filter) end
      it "non-dot, slash" do @bajs.load_action(":0:","admin-ml/", @filter) end
      it "non-dot, non-slash" do @bajs.load_action(":0:","admin-ml", @filter) end
      it "dot, slash" do @bajs.load_action(":0:",".admin-ml/", @filter) end
      after(:each) do
        @filter.actions.last.contents.should == ["move_message_to", "admin-ml"]
      end
    end

    context "Move Message to, for:" do
      it ":0" do @bajs.load_action(":0", ".admin-ml/", @filter) end
      it ":0:" do @bajs.load_action(":0", ".admin-ml/", @filter) end
      it ":0 :" do @bajs.load_action(":0", ".admin-ml/", @filter) end
      after(:each) do
        @filter.actions.last.contents.should == ["move_message_to", "admin-ml"]
      end
    end

    context "Copy Message to, for:" do
      it ":0c" do @bajs.load_action(":0c", ".admin-ml/", @filter) end
      it ":0c:" do @bajs.load_action(":0c", ".admin-ml", @filter) end
      after(:each) do
        @filter.actions.last.contents.should == ["copy_message_to", "admin-ml"]
      end
    end

    context "Forward Message to, for:" do
      it "! x" do @bajs.load_action(":0", "! test@example.com", @filter) end
      it "!x" do @bajs.load_action(":0", "!test@example.com", @filter) end
      after(:each) do
        @filter.actions.last.contents.should == ["forward_message_to", "test@example.com"]
      end
    end    

    context "Forward Copy to, for:" do
      it ":0c, ! x" do @bajs.load_action(":0c", "! test@example.com", @filter) end
      it ":0c:, ! x" do @bajs.load_action(":0c", "! test@example.com", @filter) end
      it ":0c, !x" do @bajs.load_action(":0c", "!test@example.com", @filter) end
      it ":0c:, !x" do @bajs.load_action(":0c", "!test@example.com", @filter) end
      after(:each) do
        @filter.actions.last.contents.should == ["forward_copy_to", "test@example.com"]
      end
    end

  end

  context "#load_rule", :load_rule => true do
    before(:each){ @filter = Filter.new }

    it "splits up in section, substance and part" do
      @bajs.load_rule("*^To:.*admin-ml.*@.*riec.*", @filter)
      @filter.rules_contents.should == [["to", "admin-ml.*@.*riec", "contains"]]
    end

    it "can add multiple rules" do
      @bajs.load_rule("*^To:.*admin-ml.*@.*riec.*", @filter)
      @bajs.load_rule("*^Subject: yeah!", @filter)
      @filter.rules_contents.should ==
        [["to", "admin-ml.*@.*riec", "contains"], ["subject", "yeah!", "begins_with"]]
    end

    context "split up a rule where the splitter is" do
      it ":.*" do @bajs.load_rule("*^To:.*admin-ml.*@.*riec.*", @filter) end
      it ".*" do @bajs.load_rule("*^To.*admin-ml.*@.*riec.*", @filter) end
      it ": " do @bajs.load_rule("*^To: admin-ml.*@.*riec.*", @filter) end
      it ": " do @bajs.load_rule("*^To:  admin-ml.*@.*riec.*", @filter) end

      after(:each) do
        @filter.rules.last.section.should == "to"
        @filter.rules.last.substance.should == "admin-ml.*@.*riec"
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
        @bajs.load_part("admin-ml*^@.*riec.*").should == "begins_with"
      end
      it "begins with" do
        @bajs.load_part("admin-ml*^@.*riec").should == "begins_with"
      end
        
      it "ends with" do
        @bajs.load_part(".*admin-ml*^@.*riec$").should == "ends_with"
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

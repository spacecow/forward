# -*- coding: utf-8 -*-
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
  
    it "should raise an error if * is missing in front of the rule", :bajs => true do
      filter = ":0:\n^Subject:.*something\n.Junk/"
      lambda{@bajs.load_filters(filter)}.should raise_error(FilterLoadException)
    end

    context "should raise an error if destination" do
      it "doesn't start with a dot" do
        @filter = ":0:\n^Subject:.*something\nJunk/"
      end
      it "doesn't end with a backslash" do
        @filter = ":0:\n^Subject:.*something\n.Junk"
      end

      after(:each) do
        lambda{@bajs.load_filters(@filter)}.should raise_error(FilterLoadException)
      end
    end

    it "should handle spam" do
      filter = ":0:\n*^(X-Spam-Flag|X-Barracuda-Spam-Flag):.*YES\n.Junk/"
      lambda{@bajs.load_filters(filter)}.should_not raise_error(KeywordException)
    end
  end

  context "#rule_to_file" do
    it "saves single japanese subject" do
      rule = Rule.create(:section => "subject", :part => "is", :substance => "楽しい")
      rule.to_file.should eq "* SUB ?? ^楽しい$"
    end
    it "saves single japanese recipient" do
      rule = Rule.create(:section => "from", :part => "ends_with", :substance => "楽しい")
      rule.to_file.should eq "* SEN ?? 楽しい$"
    end
    it "saves single japanese sender" do
      rule = Rule.create(:section => "to", :part => "begins_with", :substance => "楽しい")
      rule.to_file.should eq "* REC ?? ^楽しい"
    end
    it "saves single japanese cc" do
      rule = Rule.create(:section => "cc", :part => "contains", :substance => "楽しい")
      rule.to_file.should eq "* CCC ?? 楽しい"
    end
    it "saves single japanese to_or_cc" do
      rule = Rule.create(:section => "to_or_cc", :part => "contains", :substance => "楽しい")
      rule.to_file.should eq "* TOC ?? 楽しい"
    end

    it "saves double japanese subject" do
      filter = Factory(:filter, :glue => "or")
      filter.rules << Factory(:rule,:section => Rule::SUBJECT, :part => Rule::BEGINS_WITH, :substance => "楽しい")
      filter.rules << Factory(:rule,:section => Rule::SUBJECT, :part => Rule::IS, :substance => "面白い")
      filter.rules_to_file.should eq "* SUB ?? (^楽しい|^面白い$)"
    end

    it "saves mixed english/japanese subject" do
      filter = Factory(:filter, :glue => "or")
      filter.rules << Factory(:rule,:section => Rule::SUBJECT, :part => Rule::BEGINS_WITH, :substance => "english")
      filter.rules << Factory(:rule,:section => Rule::SUBJECT, :part => Rule::IS, :substance => "日本語")
      filter.rules_to_file.should eq "* SUB ?? (^english|^日本語$)"
    end

    context "different sections, at least one jap" do
      before(:each) do
        @filter = Factory(:filter)
        @filter.rules << Factory(:rule,:section => Rule::SUBJECT, :part => Rule::BEGINS_WITH, :substance => "日本語")
        @filter.rules << Factory(:rule,:section => Rule::TO, :part => Rule::IS, :substance => "english")
      end
      it "glue=or, DeMorgan" do
        @filter.glue = "or"
        @filter.rules_to_file.should eq "* ! SUB ?? ^日本語\n* ! ^To:\\s+english$" 
      end
      it "glue=and" do
        @filter.glue = "and"
        @filter.rules_to_file.should eq "* SUB ?? ^日本語\n*^To:\\s+english$" 
      end
    end

    it "saves mixex japanese/english subject" do
      filter = Factory(:filter, :glue => "or")
      filter.rules << Factory(:rule,:section => Rule::SUBJECT, :part => Rule::IS, :substance => "日本語")
      filter.rules << Factory(:rule,:section => Rule::SUBJECT, :part => Rule::BEGINS_WITH, :substance => "english")
      filter.rules_to_file.should eq "* SUB ?? (^日本語$|^english)"
    end

    it "saves double japanese recipients" do
      filter = Factory(:filter, :glue => "or")
      filter.rules << Factory(:rule,:section => Rule::TO, :part => Rule::BEGINS_WITH, :substance => "鞍馬")
      filter.rules << Factory(:rule,:section => Rule::TO, :part => Rule::IS, :substance => "天狗")
      filter.rules_to_file.should eq "* REC ?? (^鞍馬|^天狗$)"
    end

    it "saves double japanese senders" do
      filter = Factory(:filter, :glue => "or")
      filter.rules << Factory(:rule,:section => Rule::FROM, :part => Rule::BEGINS_WITH, :substance => "鞍馬")
      filter.rules << Factory(:rule,:section => Rule::FROM, :part => Rule::IS, :substance => "天狗")
      filter.rules_to_file.should eq "* SEN ?? (^鞍馬|^天狗$)"
    end

    it "saves double japanese ccs" do
      filter = Factory(:filter, :glue => "or")
      filter.rules << Factory(:rule,:section => Rule::CC, :part => Rule::BEGINS_WITH, :substance => "鞍馬")
      filter.rules << Factory(:rule,:section => Rule::CC, :part => Rule::IS, :substance => "天狗")
      filter.rules_to_file.should eq "* CCC ?? (^鞍馬|^天狗$)"
    end

    it "saves double japanese to_or_ccs" do
      filter = Factory(:filter, :glue => "or")
      filter.rules << Factory(:rule,:section => Rule::TO_OR_CC, :part => Rule::BEGINS_WITH, :substance => "鞍馬")
      filter.rules << Factory(:rule,:section => Rule::TO_OR_CC, :part => Rule::IS, :substance => "天狗")
      filter.rules_to_file.should eq "* TOC ?? (^鞍馬|^天狗$)"
    end

    it "saves single english" do
      rule = Rule.create(:section => "subject", :part => "is", :substance => "fnwo291- 320-[]w@f")
      rule.to_file.should eq "*^Subject:\\s+fnwo291- 320-[]w@f$"
    end
  end

  describe "#save_filters" do
    context "writes a" do
        
      it "default prolog" do
        @bajs.save_filters("test","correct","",[])
        arr, prolog = @bajs.read_filters("test","correct") 
        prolog.should eq ["MAILDIR=$HOME/Maildir/","DEFAULT=$MAILDIR","SHELL=/bin/sh"]
      end

      Rule::JAPANESE_SECTIONS.each do |section|
        it "#{section} conversation if written in japanese" do
          filter = Factory(:filter)
          rule = Factory(:rule,:section => section,:substance => "日本語")
          filter.rules << rule
          @bajs.save_filters("test","correct","",[filter])
          arr, prolog, convs = @bajs.read_filters("test","correct") 
          convs.should eq [":0:conversion_#{section}","*^#{rule.send("section_to_file_in_english")}:\/.*","#{rule.send("section_to_file_in_japanese")}=| echo \"$MATCH\" | perl /usr/local/bin/convert_japanese.pl -d", ""]
        end
      end
    end
  end

  describe "#to_file" do
    context "different sections, at least one jap" do
      before(:each) do
        @filter = Factory(:filter)
        @filter.actions.destroy_all
        @filter.rules << Factory(:rule,:section => Rule::SUBJECT, :part => Rule::BEGINS_WITH, :substance => "日本語")
        @filter.rules << Factory(:rule,:section => Rule::TO, :part => Rule::IS, :substance => "english")
        @filter.actions << Factory(:action,:destination => "japanese")
      end

      it "glue = and" do
        @filter.glue = "and"
        @filter.to_file.should eq ":0\n* SUB ?? ^日本語\n*^To:\\s+english$\n.japanese/"
      end

      context "DeMorgan, glue = or" do
        before(:each) do
          @filter.glue = "or"
        end

        it "move to folder" do
          @filter.actions.last.operation = Action::MOVE_MESSAGE_TO
          @filter.to_file.should eq ":0\n* ! SUB ?? ^日本語\n* ! ^To:\\s+english$\n{ }\n:0E:\n.japanese/"
        end
        it "copy to folder" do
          @filter.actions.last.operation = Action::COPY_MESSAGE_TO
          @filter.to_file.should eq ":0\n* ! SUB ?? ^日本語\n* ! ^To:\\s+english$\n{ }\n:0Ec:\n.japanese/"
        end
        it "forward message" do
          @filter.actions.last.operation = Action::FORWARD_MESSAGE_TO
          @filter.to_file.should eq ":0\n* ! SUB ?? ^日本語\n* ! ^To:\\s+english$\n{ }\n:0E\n!japanese"
        end
        it "forward copy" do
          @filter.actions.last.operation = Action::FORWARD_COPY_TO
          @filter.to_file.should eq ":0\n* ! SUB ?? ^日本語\n* ! ^To:\\s+english$\n{ }\n:0Ec\n!japanese"
        end
      end
    end
  end

  context "#save_filters", :save_filters => true do
    before(:each) do
      @filter = Filter.create
      @filter.actions.destroy_all
      @filter.rules << Rule.create(:section => "subject", :part => "contains", :substance => "yeah")
      @filter.actions << Action.create(:operation => "Move Message to", :destination => "temp")
      @filter.save
    end

    it "saves a users filter to file" do
      @bajs.save_filters("test", "correct", "", [@filter])
      arr, prolog = @bajs.read_filters("test", "correct")
      arr.first.contents.should == 
        [[["subject", "yeah", "contains"]],[["move_message_to", "temp"]]]
    end

    context "#rules_to_file", :rules_to_file => true do
      it "escapes dots in substance" do
        Rule.create(:section => "to", :part => "is", :substance => "yeah.com", :filter_id => @filter.id)
        @filter.rules_to_file.should == "*^Subject:.*yeah\n*^To:\\s+yeah\\.com$"
      end

      it "has 1 lines for 1 rule" do
        @filter.rules_to_file.should eq "*^Subject:.*yeah"
      end

      context "has 1 line for 2 OR-rules" do
        before(:each) do @filter.glue = "or" end
        it "with the same section" do
          Rule.create(:section => "subject", :part => "is", :substance => "oh boy", :filter_id => @filter.id)
          @filter.rules_to_file
          @filter.rules_to_file.should == "*^Subject:(.*yeah|\\s+oh boy$)"
        end

        it "with different sections" do
          Rule.create(:section => "to", :part => "is", :substance => "oh boy", :filter_id => @filter.id)
          @filter.rules_to_file
          @filter.rules_to_file.should == "*^Subject:.*yeah|^To:\\s+oh boy$"
        end
      end

      it "has 2 lines for 2 AND-rules" do
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
        @filter.to_file.should eq ":0\n*^Subject:.*yeah\n!example@gmail\.com" 
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
      arr, prolog = @bajs.load_filters(":0 :\n*^To:.*admin-ml*^@.*riec.*\n.admin-ml/")
      arr.first.rules_to_s.should == ["^To:.*admin-ml*^@.*riec"]
    end

    it "contains" do 
      arr, prolog = @bajs.load_filters(":0 :\n*^To:.*admin-ml*^@.*riec\n.admin-ml/")
      arr.first.rules_to_s.should == ["^To:.*admin-ml*^@.*riec"]
    end

    it "is" do 
      arr, prolog = @bajs.load_filters(":0 :\n*^To:\\s+admin-ml*^@.*riec$\n.admin-ml/")
      arr.first.rules_to_s.should == ["^To:\\s+admin-ml*^@.*riec$"]
    end

    it "begins with ending with star" do 
      arr, prolog = @bajs.load_filters(":0 :\n*^To:\\s+admin-ml*^@.*riec.*\n.admin-ml/")
      arr.first.rules_to_s.should == ["^To:\\s+admin-ml*^@.*riec"]
    end
 
    it "begins with" do 
      arr, prolog = @bajs.load_filters(":0 :\n*^To:\\s+admin-ml*^@.*riec\n.admin-ml/")
      arr.first.rules_to_s.should == ["^To:\\s+admin-ml*^@.*riec"]
    end

    it "ends with" do 
      arr, prolog = @bajs.load_filters(":0 :\n*^To:.*admin-ml.*@.*riec$\n.admin-ml/")
      arr.first.rules_to_s.should == ["^To:.*admin-ml.*@.*riec$"]
    end
  end
  
  context "#actions_to_s", :actions_to_s => true do
    before(:each) do
      @filter = Filter.create
      rule = Factory.build(:rule, :filter_id => @filter.id)
      action = Action.create(:operation => "move_message_to", :destination => "temp", :filter_id => @filter.id)
    end

    it "has 1 line for 1 action" do
      @filter.actions_to_s.should eq ["temp"]
    end

    it "has 2 lines for 2 actions" do
      Action.create(:operation => "forward_message_to", :destination => "example@gmail.com", :filter_id => @filter.id)
      @filter.actions_to_s.should eq ["temp", "example@gmail.com"]
    end
  end

  context "#load_filters", :load_filters => true do
    it "returns an empty array if file is empty" do
      arr, prolog = @bajs.load_filters("")
      arr.should be_empty
    end
      
    it "returns 1 filter in an array" do
      arr, prolog = @bajs.load_filters(":0 :\n*^To:.*admin-ml*^@.*riec.*\n.admin-ml/")
      arr.size.should == 1
      arr.last.contents.should == [[["to", "admin-ml*^@.*riec", "contains"]],[["move_message_to", "admin-ml"]]]
    end

    it "returns 2 filters in an array" do
      arr, prolog = @bajs.load_filters(":0 :\n*^To:.*admin-ml*^@.*riec.*\n.admin-ml/\n\n:0 :\n*^Cc:.*fir@.*riec.*\n.fir-cc/")
      arr.size.should == 2
      arr.first.contents.should == [[["to", "admin-ml*^@.*riec", "contains"]],[["move_message_to", "admin-ml"]]]
      arr.last.contents.should == [[["cc", "fir@.*riec", "contains"]],[["move_message_to", "fir-cc"]]]
    end
  end

  describe "DeMorgan rule" do
    describe "#to_file" do
      it "japanese folder in utf7-imap encoding" do
        filter = Factory(:filter)
        filter.rules << Factory(:rule,:section => Rule::SUBJECT, :part => Rule::CONTAINS, :substance => "日本語")
        filter.actions << Factory(:action,:operation => Action::MOVE_MESSAGE_TO,:destination => "日本語")
        filter.to_file.should eq ":0:\n* SUB ?? 日本語\n.&ZeVnLIqe-/"
      end

      context "two actions, copy message to" do
        before(:each) do
          @filter = Factory(:filter)
          @filter.actions.destroy_all
          @filter.rules << Factory(:rule,:section => Rule::SUBJECT, :part => Rule::CONTAINS, :substance => "日本語")
          @filter.rules << Factory(:rule,:section => Rule::TO, :part => Rule::BEGINS_WITH, :substance => "english@example.com")
          @filter.actions << Factory(:action,:operation => Action::COPY_MESSAGE_TO,:destination => "temp")
          @filter.glue = "or"
        end

        it "move message to" do
          @filter.actions << Factory(:action,:operation => Action::MOVE_MESSAGE_TO,:destination => "temporary")
          @filter.to_file.should eq ":0\n* ! SUB ?? 日本語\n* ! ^To:\\s+english@example\\.com\n{ }\n:0E\n{\n\t:0c:\n\t.temp/\n\n\t:0:\n\t.temporary/\n}"
        end
        it "copy message to" do
          @filter.actions << Factory(:action,:operation => Action::COPY_MESSAGE_TO,:destination => "temporary")
          @filter.to_file.should eq ":0\n* ! SUB ?? 日本語\n* ! ^To:\\s+english@example\\.com\n{ }\n:0E\n{\n\t:0c:\n\t.temp/\n\n\t:0c:\n\t.temporary/\n}"
        end
        it "forward message to" do
          @filter.actions << Factory(:action,:operation => Action::FORWARD_MESSAGE_TO,:destination => "temporary@example.com")
          @filter.to_file.should eq ":0\n* ! SUB ?? 日本語\n* ! ^To:\\s+english@example\\.com\n{ }\n:0E\n{\n\t:0c:\n\t.temp/\n\n\t:0\n\t!temporary@example.com\n}"
        end
        it "forward copy to" do
          @filter.actions << Factory(:action,:operation => Action::FORWARD_COPY_TO,:destination => "temporary@example.com")
          @filter.to_file.should eq ":0\n* ! SUB ?? 日本語\n* ! ^To:\\s+english@example\\.com\n{ }\n:0E\n{\n\t:0c:\n\t.temp/\n\n\t:0c\n\t!temporary@example.com\n}"
        end
      end
    end

    context "#load_filters" do
      it "one filter" do 
        filters, prolog = @bajs.load_filters(":0\n* ! SUB ?? 楽しい\n* ! ^Subject:\\s+English\n{ }\n:0E:\n.japanese/")
        filters.first.contents.should eq [[["subject","楽しい","contains"],["subject","English","begins_with"]],[["move_message_to","japanese"]]]
      end

      it "two filters, close brackets" do
        filters, prolog = @bajs.load_filters(":0\n* ! SUB ?? 楽しい\n* ! ^To:\\s+user\n{ }\n:0E:\n.japanese/\n\n:0:\n*^Subject:\\s+spam$\n.junk/")
        filters.first.contents.should eq [[["subject","楽しい","contains"],["to","user","begins_with"]],[["move_message_to","japanese"]]]
        filters.last.contents.should eq [[["subject","spam","is"]],[["move_message_to","junk"]]]
      end
    end

    it "just one in the array" do
      filters, prolgo = @bajs.load_filters(":0\n* ! SUB ?? 楽しい\n* ! ^Subject:\\s+English\n{ }\n:0E:\n.japanese/")
      filters.size.should be 1
    end

    context "#load_filter" do
      context "one action" do
        it "move message to" do
          @filter = @bajs.load_filter(":0",["* ! SUB ?? 楽しい","* ! ^Subject:\\s+English","{ }",":0E:",".japanese/"])
          @filter.actions_contents.should eq [["move_message_to","japanese"]]
        end
        it "copy message to" do
          @filter = @bajs.load_filter(":0",["* ! SUB ?? 楽しい","* ! ^Subject:\\s+English","{ }",":0Ec:",".japanese/"])
          @filter.actions_contents.should eq [["copy_message_to","japanese"]]
        end
        it "forward message to" do
          @filter = @bajs.load_filter(":0",["* ! SUB ?? 楽しい","* ! ^Subject:\\s+English","{ }",":0E","!test@example.com"])
          @filter.actions_contents.should eq [["forward_message_to","test@example.com"]]
        end
        it "forward copy to" do
          @filter = @bajs.load_filter(":0",["* ! SUB ?? 楽しい","* ! ^Subject:\\s+English","{ }",":0Ec","!test@example.com"])
          @filter.actions_contents.should eq [["forward_copy_to","test@example.com"]]
        end
      
        after(:each) do
          @filter.rules_contents.should eq [["subject","楽しい","contains"],["subject","English","begins_with"]]
          @filter.glue.should eq "or"
        end
      end

      context "two actions" do
        it "copy message to, move message to" do
          @filter = @bajs.load_filter(":0",["* ! SUB ?? 楽しい","* ! ^Subject:\\s+English","{ }",":0E","{", "\t:0c:", "\t.temp/", "\n", "\t:0:", "\t.temporary/", "\}"])
          @filter.actions_contents.should eq [["copy_message_to","temp"],["move_message_to","temporary"]]
        end
        it "forward copy to, copy message to" do
          @filter = @bajs.load_filter(":0",["* ! SUB ?? 楽しい","* ! ^Subject:\\s+English","{ }",":0E","{", "\t:0c", "\t!temp@example.com", "\n", "\t:0c:", "\t.temporary/", "\}"])
          @filter.actions_contents.should eq [["forward_copy_to","temp@example.com"],["copy_message_to","temporary"]]
        end
        it "copy message to, forward copy to" do
          @filter = @bajs.load_filter(":0",["* ! SUB ?? 楽しい","* ! ^Subject:\\s+English","{ }",":0E","{", "\t:0c:", "\t.temp/", "\n", "\t:0c", "\t!temporary@example.com", "\}"])
          @filter.actions_contents.should eq [["copy_message_to","temp"],["forward_copy_to","temporary@example.com"]]
        end
        it "forward copy to, forward message to" do
          @filter = @bajs.load_filter(":0",["* ! SUB ?? 楽しい","* ! ^Subject:\\s+English","{ }",":0E","{", "\t:0c", "\t!temp@example.com", "\n", "\t:0", "\t!temporary@example.com", "\}"])
          @filter.actions_contents.should eq [["forward_copy_to","temp@example.com"],["forward_message_to","temporary@example.com"]]
        end

        after(:each) do
          @filter.rules_contents.should eq [["subject","楽しい","contains"],["subject","English","begins_with"]]
          @filter.glue.should eq "or"
        end
      end
    end

    context "#load_rule" do
      it "japanese" do
        filter = Factory(:filter)
        @bajs.load_rule('* ! SUB ?? 楽しい', filter)
        filter.rules_contents.should == [["subject", '楽しい', "contains"]]
      end
      it "english" do
        filter = Factory(:filter)
        @bajs.load_rule("* ! ^Subject:\\s+English", filter)
        filter.rules_contents.should == [["subject", 'English', "begins_with"]]
      end
    end

  end

  describe "#load_filter", :load_filter => true do
    context "can read japanese" do
      it "subject" do
        filter = @bajs.load_filter(":0:",["* SUB ?? .*楽しい.*",".japanese/"])
        filter.rule_contents.should eq ["subject","楽しい","contains"]
      end
      it "recipient" do
        filter = @bajs.load_filter(":0:",["* REC ?? 宛先",".japanese/"])
        filter.rule_contents.should eq ["to","宛先","contains"]
      end
      it "sender" do
        filter = @bajs.load_filter(":0:",["* SEN ?? ^差出人",".japanese/"])
        filter.rule_contents.should eq ["from","差出人","begins_with"]
      end
    end

    it "can read two or-rules in japanese" do
      filter = @bajs.load_filter(":0:",["* SUB ?? (楽しい|^面白い$)",".japanese/"])
      filter.first_rules_contents.should eq ["subject","楽しい","contains"]
      filter.last_rules_contents.should eq ["subject","面白い","is"]
    end

    it "splits up in rule and action" do
      filter = @bajs.load_filter(":0:",["*^To:.*admin-ml*^@.*riec.*", ".admin-ml/"])
      filter.rules.last.contents.should == ["to", "admin-ml*^@.*riec", "contains"]
      filter.actions.last.contents.should == ["move_message_to", "admin-ml"]
    end 

    it "can load two actions" do
      filter = @bajs.load_filter(":0", ['*^To:\\s+test@example\.com', "{", "\t:0c:", "\t.temp/", "\n", "\t:0c:", "\t.temporary/", "\}"])
      filter.rules_contents.should == [["to", "test@example.com", "begins_with"]]
      filter.actions_contents.should == [["copy_message_to", "temp"],["copy_message_to", "temporary"]]
    end

    it "can load two rules" do
      filter = @bajs.load_filter(":0:",["*^Subject:(.yeah| bull$)"])
    end
  end
    
  context "#load_action", :load_action => true do
    before(:each){ @filter = Filter.new }

    it "decodes utf7-imap destination" do
      @bajs.load_action(":0:",".&ZeVnLIqe-/",@filter)
      @filter.action_destination.should eq "日本語"
    end

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

    context "raises an error if destination folder contains" do
      it "dot, non-slash" do @dest = ".admin-ml" end
      it "non-dot, slash" do @dest = "admin-ml/" end
      it "non-dot, non-slash" do @dest = "admin-ml" end

      after(:each) do
        lambda{@bajs.load_action(":0:",@dest,@filter)}.should raise_error(FilterLoadException)
      end
    end

    it "creates a destination folder with dot and slash" do
      @bajs.load_action(":0:",".admin-ml/", @filter)
      @filter.actions.last.contents.should == ["move_message_to", "admin-ml"]
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
      it ":0c:" do @bajs.load_action(":0c", ".admin-ml/", @filter) end
      after(:each) do
        @filter.actions.last.contents.should == ["copy_message_to", "admin-ml"]
      end
    end

    context "Forward Message to, for:" do
      it "! x" do @bajs.load_action(":0", "! test@example\.com", @filter) end
      it "!x" do @bajs.load_action(":0", "!test@example\.com", @filter) end
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

  context "#split_substance", :split_substance => true do
    before(:each){ @filter = Filter.new }

    it "does nothing to a regular regex" do
      @bajs.split_substance("SPAM").should == ["SPAM"]
    end

    it "deletes a regular paranthesis" do
      @bajs.split_substance("(SPAM)").should == ["SPAM"]
    end
    
    it "adds whats before the paranthesis to every element" do
      @bajs.split_substance(".*(SPAM|JUNK)").should == [".*SPAM", ".*JUNK"]
    end

    it "adds whats after the paranthesis to every element" do
      @bajs.split_substance("(SPAM|JUNK).*").should == ["SPAM.*", "JUNK.*"]
    end

    it "adds whats before&after the paranthesis to every element" do
      @bajs.split_substance(".*(SPAM|JUNK).*").should == [".*SPAM.*", ".*JUNK.*"]
    end

  end

  context "#load_rule", :load_rule => true do
    before(:each){ @filter = Filter.new }

    it "can have a space in between hat and star" do
      @bajs.load_rule('* ^To:.*admin-ml.*@.*riec', @filter)
      @filter.rules_contents.should == [["to", 'admin-ml.*@.*riec', "contains"]]
    end

    context "dots in substance" do
      it "unescapes dots" do
        @bajs.load_rule('*^To:.*admin-ml.*@.*riec\.com', @filter)
        @filter.rules_contents.should == [["to", 'admin-ml.*@.*riec.com', "contains"]]
      end

      context "raises an error on unescaped dots" do
        it "a.b" do @pat = '*^TO.*a.b' end
        after(:each) do
          lambda{@bajs.load_rule(@pat,@filter)}.should raise_error(RuleLoadException)
        end
      end
  
      context "does not raise an error on escaped dots" do
        it "a\.*b" do @pat = '*^TO.*a\.*b' end
        it "a\.b" do @pat = '*^TO.*a\.b' end
        it "a.*b" do @pat = '*^TO.*a.*b' end
        after(:each) do
          lambda{@bajs.load_rule(@pat,@filter)}.should_not raise_error(RuleLoadException)
        end
      end
    end

    it "splits up in section, substance and part" do
      @bajs.load_rule("*^To:.*admin-ml.*@.*riec.*", @filter)
      @filter.rules_contents.should == [["to", "admin-ml.*@.*riec", "contains"]]
    end

    context "can load OR-rules with" do
      it "same section" do
        @bajs.load_rule("*^From:(.*DELLNEWS.*|newsmail@sios.*)", @filter)
        @filter.rules_contents.should == [["from", "DELLNEWS", "contains"], ["from", "newsmail@sios", "begins_with"]]
      end

      it "To|Cc" do
        @bajs.load_rule("*^(To|Cc):.*(kazuto|johokiki-fri2)@.*miyakyo-u.*", @filter)
        @filter.rules_contents.should == [["to_or_cc", "kazuto@.*miyakyo-u", "contains"], ["to_or_cc", "johokiki-fri2@.*miyakyo-u", "contains"]] 
        @filter.glue.should == "or"
      end

      context "different sections and paranthesis + ch" do 

        it "before&after" do
          @bajs.load_rule("*^(Subject:.*yeah|To:\\s+oh boy)$", @filter)
        end

        it "after" do 
          @bajs.load_rule("*(^Subject:.*yeah|^To:\\s+oh boy)$", @filter)
        end

        it "before" do 
          @bajs.load_rule("*^(Subject:.*yeah$|To:\\s+oh boy$)", @filter)
        end

        it "that's it" do 
          @bajs.load_rule("*(^Subject:.*yeah$|^To:\\s+oh boy$)", @filter)
        end

        it "actually, no parenthesis" do
          @bajs.load_rule("*^Subject:.*yeah$|^To:\\s+oh boy$", @filter)
        end

        after(:each) do
          @filter.rules_contents.should == [["subject", "yeah", "ends_with"], ["to", "oh boy", "is"]] 
          @filter.glue.should == "or"
        end
      end
    end

    it "can add multiple rules" do
      @bajs.load_rule("*^To:.*admin-ml.*@.*riec.*", @filter)
      @bajs.load_rule("*^Subject:\\s+yeah!", @filter)
      @filter.rules_contents.should ==
        [["to", "admin-ml.*@.*riec", "contains"], ["subject", "yeah!", "begins_with"]]
      @filter.glue.should == "and"
    end

    context "split up a rule where the splitter is" do
      it ":.*" do @bajs.load_rule("*^To:.*admin-ml.*@.*riec.*", @filter) end
      it ".*" do @bajs.load_rule("*^To.*admin-ml.*@.*riec.*", @filter) end
      it ": " do @bajs.load_rule("*^To:\\s+admin-ml.*@.*riec.*", @filter) end
      #it ":  " do @bajs.load_rule("*^To:  admin-ml.*@.*riec.*", @filter) end

      after(:each) do
        @filter.rules.last.section.should == "to"
        @filter.rules.last.substance.should == "admin-ml.*@.*riec"
      end
    end

    context "#load_part to" do
      context "in japanese" do
        it "contains with stars" do
          @bajs.load_part(".*楽しい.*").should == Rule::CONTAINS 
        end
        it "contains with beginning star" do
          @bajs.load_part(".*楽しい").should == Rule::CONTAINS 
        end
        it "contains with end star" do
          @bajs.load_part("楽しい.*").should == Rule::CONTAINS 
        end
        it "contains with no star" do
          @bajs.load_part("楽しい").should == Rule::CONTAINS 
        end

        it "ends with, with star" do
          @bajs.load_part(".*楽しい$").should == Rule::ENDS_WITH
        end
        it "ends with, without star" do
          @bajs.load_part("楽しい$").should == Rule::ENDS_WITH
        end

        it "begins with, with star" do
          @bajs.load_part("^楽しい.*").should == Rule::BEGINS_WITH
        end
        it "begins with, without star" do
          @bajs.load_part("^楽しい").should == Rule::BEGINS_WITH
        end

        it "is" do
          @bajs.load_part("^楽しい$").should == Rule::IS
        end
      end

      context "in english" do
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

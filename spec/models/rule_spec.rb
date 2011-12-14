# -*- coding: utf-8 -*-
require 'spec_helper'

describe Rule do
  describe "#beginning_to_file" do
    context "in english for" do
      it "subject" do
        rule = Factory(:rule,:section => "subject")
        rule.beginning_to_file.should eq "^Subject:"
      end
      it "from" do
        rule = Factory(:rule,:section => "from")
        rule.beginning_to_file.should eq "^From:"
      end
    end

    context "in japanese for" do
      it "subject" do
        rule = Factory(:rule,:section => "subject",:substance => "楽しい")
        rule.beginning_to_file.should eq " SUB ?? "
      end
      it "from" do
        rule = Factory(:rule,:section => "from",:substance => "鞍馬天狗")
        rule.beginning_to_file.should eq "^From:"
      end
    end
  end

  describe "#end_to_file, subject" do
    context "in english for" do
      before(:each) do
        @rule = Factory(:rule,:substance => "spam",:section => Rule::SUBJECT)
      end

      it "contains" do
        @rule.part = Rule::CONTAINS
        @rule.end_to_file.should eq ".*spam" 
      end

      it "is" do
        @rule.part = Rule::IS
        @rule.end_to_file.should eq " spam$" 
      end

      it "begins with" do
        @rule.part = Rule::BEGINS_WITH
        @rule.end_to_file.should eq " spam" 
      end

      it "ends with" do
        @rule.part = Rule::ENDS_WITH
        @rule.end_to_file.should eq ".*spam$" 
      end
    end

    context "in japanese for" do
      before(:each) do
        @rule = Factory(:rule,:substance => "楽しい",:section => Rule::SUBJECT)
      end

      it "contains" do
        @rule.part = Rule::CONTAINS
        @rule.end_to_file.should eq "楽しい"
      end

      it "is" do
        @rule.part = Rule::IS
        @rule.end_to_file.should eq "^楽しい$"
      end 

      it "begins with" do
        @rule.part = Rule::BEGINS_WITH
        @rule.end_to_file.should eq "^楽しい"
      end 

      it "ends with" do
        @rule.part = Rule::ENDS_WITH
        @rule.end_to_file.should eq "楽しい$"
      end 
    end
  end

  context "#substance" do
    context "escapes dots" do
      before(:each) do
        @rule = Rule.new(:section => Rule::SUBJECT, :part => Rule::CONTAINS, :substance => "J.R.")
      end

      it "not before save" do
        @rule.substance.should == "J.R."
      end

      it "not after save" do
        @rule.save
        @rule.substance.should == 'J.R.'        
      end
    end

    it "unescape dots a user has esacped" do
      rule = Rule.new(:section => Rule::SUBJECT, :part => Rule::CONTAINS, :substance => 'J\.R\.')
      rule.substance.should == "J.R." 
    end
  end

  context "#map_section for", :map_section => true do
    it "subject" do Rule.map_section("Subject").should == "subject" end     
    it "SUB" do Rule.map_section("SUB").should == "subject" end
    it "to" do Rule.map_section("To").should == "to" end
    it "cc" do Rule.map_section("Cc").should == "cc" end
    it "from" do Rule.map_section("From").should == "from" end
    it "x-spam-flag" do
      Rule.map_section("X-Spam-Flag|X-Barracuda-Spam-Flag").should == "spam_flag"
      Rule.map_section("(X-Spam-Flag|X-Barracuda-Spam-Flag)").should == "spam_flag"
      Rule.map_section("X-Barracuda-Spam-Flag").should == "spam_flag"
      Rule.map_section("X-Spam-Flag").should == "spam_flag"
    end
    it "to_or_cc" do
      Rule.map_section("(To|CC)").should == "to_or_cc"
      Rule.map_section("CC|TO").should == "to_or_cc"
      Rule.map_section("To|Cc").should == "to_or_cc"
    end
  end

  context "#section_to_file for", :section_to_file => true do
    it "subject" do Rule.section_to_file("subject").should == "Subject" end
    it "from" do Rule.section_to_file("from").should == "From" end
    it "to" do Rule.section_to_file("to").should == "To" end
    it "cc" do Rule.section_to_file("cc").should == "Cc" end
    it "to_or_cc" do Rule.section_to_file("to_or_cc").should == "(To|Cc)" end
    it "spam_flag" do Rule.section_to_file("spam_flag").should == "(X-Spam-Flag|X-Barracuda-Spam-Flag)" end
  end
end


# == Schema Information
#
# Table name: rules
#
#  id         :integer(4)      not null, primary key
#  section    :string(255)
#  part       :string(255)
#  substance  :string(255)
#  created_at :datetime
#  updated_at :datetime
#  filter_id  :integer(4)
#


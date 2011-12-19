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
      it "to" do
        rule = Factory(:rule,:section => "to")
        rule.beginning_to_file.should eq "^To:"
      end
    end

    context "in japanese for" do
      it "subject" do
        rule = Factory(:rule,:section => "subject",:substance => "楽しい")
        rule.beginning_to_file.should eq " SUB ?? "
      end
      it "from" do
        rule = Factory(:rule,:section => "from",:substance => "差出人")
        rule.beginning_to_file.should eq " SEN ?? "
      end
      it "to" do
        rule = Factory(:rule,:section => "to",:substance => "宛先")
        rule.beginning_to_file.should eq " REC ?? "
      end
      it "cc" do
        rule = Factory(:rule,:section => "cc",:substance => "宛先")
        rule.beginning_to_file.should eq " CCC ?? "
      end
      it "to_or_cc" do
        rule = Factory(:rule,:section => "to_or_cc",:substance => "宛先")
        rule.beginning_to_file.should eq " TOC ?? "
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
        @rule.end_to_file.should eq "\\s+spam$" 
      end

      it "begins with" do
        @rule.part = Rule::BEGINS_WITH
        @rule.end_to_file.should eq "\\s+spam" 
      end

      it "ends with" do
        @rule.part = Rule::ENDS_WITH
        @rule.end_to_file.should eq ".*spam$" 
      end
    end

    context "in japanese for" do
      before(:each) do
        @rule = Factory(:rule,:substance => "楽しい")
      end

      context "contains in" do
        before(:each) do
          @rule.part = Rule::CONTAINS
        end

        Rule::JAPANESE_SECTIONS.each do |section|
          it section do
            @rule.section = section
          end
        end
    
        after(:each) do
          @rule.end_to_file.should eq "楽しい"
        end
      end

      context "is in" do
        before(:each) do
          @rule.part = Rule::IS
        end
    
        Rule::JAPANESE_SECTIONS.each do |section|
          it section do
            @rule.section = section 
          end
        end

        after(:each) do
          @rule.end_to_file.should eq "^楽しい$"
        end
      end 

      context "begins with in" do
        before(:each) do
          @rule.part = Rule::BEGINS_WITH
        end

        Rule::JAPANESE_SECTIONS.each do |section|
          it section do
            @rule.section = section
          end
        end

        after(:each) do
          @rule.end_to_file.should eq "^楽しい"
        end
      end

      context "ends with in" do
        before(:each) do
          @rule.part = Rule::ENDS_WITH
        end

        Rule::JAPANESE_SECTIONS.each do |section|
          it section do
            @rule.section = section
          end
        end

        after(:each) do
          @rule.end_to_file.should eq "楽しい$"
        end
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
    before(:each) do
      @rule = Factory(:rule,:substance=>"english")
    end

    it "subject" do
      @rule.section = Rule::SUBJECT
      @rule.send("section_to_file").should == "Subject"
    end
    it "from" do
      @rule.section = Rule::FROM
      @rule.send("section_to_file").should == "From"
    end
    it "to" do
      @rule.section = Rule::TO
      @rule.send("section_to_file").should == "To"
    end
    it "cc" do
      @rule.section = Rule::CC
      @rule.send("section_to_file").should == "Cc"
    end
    it "to_or_cc" do
      @rule.section = Rule::TO_OR_CC
      @rule.send("section_to_file").should == "(To|Cc)"
    end
    it "spam_flag" do
      @rule.section = Rule::SPAM_FLAG
      @rule.send("section_to_file").should == "(X-Spam-Flag|X-Barracuda-Spam-Flag)"
    end
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


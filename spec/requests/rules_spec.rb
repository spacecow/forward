require 'spec_helper'

describe "Rules" do
  before(:each) do
    @user = Factory(:user, :username => "test", :password => "correct")
    login_with_user(@user)
    visit new_procmail_filter_path
  end

  describe "#substance" do
    context "unescapes escaped dots" do
      it "when error" do
        fill_in input_field_id("substance",0), :with => 'gmail\.com'
        click_button "Create"
        input_field_value("substance",0).should == "gmail.com"  
      end

      it "when saved" do
        select "Subject", :from => select_field_id("section", 0)
        select "contains", :from => select_field_id("part", 0)
        fill_in input_field_id("substance", 0), :with => 'gmail\.com' 
        fill_in_a_first_action
        click_button "Create"
        Rule.last.substance.should == "gmail.com"
        lambda{visit procmail_filters_path}.should_not raise_error(Exception)
      end
    end
  end

  describe "edit filter" do
    before(:each) do
      filter = Filter.create(:user_id => @user.id)
      Rule.create(:section => "subject", :part => "contains", :substance => "yeah", :filter_id => filter.id)
      Action.create(:operation => "move_message_to", :destination => "temp", :filter_id => filter.id)
      visit edit_procmail_filter_path(filter)
    end

    context "add rules" do
      before(:each) do
        click_button "Add Rule"
      end

      it "one" do
        @rule_count = 2
      end

      it "two" do
        click_button "Add Rule"
        @rule_count = 3
      end
      
      after(:each) do
        all(:css, "fieldset#rules").count.should == @rule_count
      end
    end

    context "delete rules" do
      it "keeps an added action" do
        click_button "Add Action"
        click_button "Delete"
        all(:css, "fieldset#actions").count.should == 2
      end

      it "keeps an edited saved action" do
        fill_in input_field_id("destination", 0), :with => "spam" 
        click_button "Delete"
        input_field_value("destination",0).should == "spam"  
      end
    end

  end

  describe "POST /rules" do
    it "create OR-rules" do
      fill_in_a_first_rule
      click_button "Add Rule"
      fill_in_a_second_rule 
      fill_in_a_first_action
      choose "Match any of the following"
      click_button "Create"
      Filter.last.glue.should == "or"
    end
  end
end

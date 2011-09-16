require 'spec_helper'

describe "Rules" do
  before(:each) do
    login_with("test","correct")
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
        Rule.first.substance.should == "gmail.com"
        lambda{visit procmail_filters_path}.should_not raise_error(Exception)
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

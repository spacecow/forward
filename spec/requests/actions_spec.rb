require 'spec_helper'

describe "Actions" do
  describe "POST /actions" do
    before(:each) do
      login_with("test","correct")
      visit new_procmail_filter_path
    end

    context "email validation" do
      before(:each) do
        select "Forward Message to", :from => select_field_id("operation", 0)
      end

      it "accepts a valid email" do
        fill_in input_field_id("destination", 0), :with => 'example@gmail.com'
        click_button "Create"
        error_field("destination", 0).should be_nil
        input_field_value("destination", 0).should == "example@gmail.com"
      end

      it "does not accept an invalid email" do
        fill_in input_field_id("destination", 0), :with => 'example'
        click_button "Create"
        error_field_mess("destination", 0).should == "invalid email address"
      end
    end
  end
end

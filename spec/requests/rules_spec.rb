require 'spec_helper'

describe "Rules" do
  describe "POST /rules" do
    before(:each) do
      login_with("test","correct")
    end

    it "create OR-rules" do
      visit new_procmail_filter_path
      fill_in_a_first_rule
      click_button "Add Rule"
      fill_in_a_second_rule 
      fill_in_a_first_action
      choose "Match any of the following"
      click_button "Create"
    end
  end
end

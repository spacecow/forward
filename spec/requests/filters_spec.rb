# -*- coding: utf-8 -*-
require 'spec_helper'

describe "Filters" do
  before(:each) do
    @user = Factory(:user, :username => "test", :password => "correct")
    login_with_user(@user)
  end

  context "switching language on the error page should let you stay" do

    it "for a new filter" do
      visit new_procmail_filter_path
      click_button "Create"
    end

    it "for a saved filter" do
      filter = create_a_first_filter(@user)
      visit edit_procmail_filter_path(filter)
      fill_in input_field_id("substance",0), :with => ""
      click_button "Update"
    end

    after(:each) do
      click_link "日本語" 
      find(:css, "form#filter") 
    end
  end
end

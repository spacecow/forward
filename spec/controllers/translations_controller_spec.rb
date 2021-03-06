require File.dirname(__FILE__) + '/../spec_helper'


describe TranslationsController do
  controller_actions = controller_actions("translations")

  before(:each) do
    @translation = Factory(:translation)
  end

  describe "a user is not logged in" do
    controller_actions.each do |action,req|
      it "should not reach the #{action} page" do
        send("#{req}", "#{action}", :id => @translation.id)
        response.redirect_url.should eq(login_url)
      end
    end
  end

  describe "an member is logged in" do
    before(:each) do
      @user = Factory(:user, :roles_mask => 4)
      session[:username] = @user.username
    end
    
    controller_actions.each do |action,req|
      it "should not reach the #{action} page" do
        send("#{req}", "#{action}", :id => @translation.id)
        response.redirect_url.should eq(welcome_url)
      end
    end    
  end

  describe "an admin is logged in" do
    before(:each) do
      @user = Factory(:user, :roles_mask => 2)
      session[:username] = @user.username
    end
    
    controller_actions.each do |action,req|
      if %w(index create delete).include?(action)
        it "should reach the #{action} page" do
          send("#{req}", "#{action}", :id => @translation.id)
          response.redirect_url.should_not eq(welcome_url)
        end
      else
        it "should not reach the #{action} page" do
          send("#{req}", "#{action}", :id => @translation.id)
          response.redirect_url.should eq(welcome_url)
        end
      end
    end    
  end
end

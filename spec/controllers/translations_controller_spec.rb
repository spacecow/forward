require File.dirname(__FILE__) + '/../spec_helper'

def controller_actions(controller)
  Rails.application.routes.routes.inject({}) do |hash, route|
    hash[route.requirements[:action]] = route.verb.downcase if route.requirements[:controller] == controller && !route.verb.nil?
    hash
  end
end

describe TranslationsController do
  controller_actions = controller_actions("translations")

  before(:each) do
    @translation = Factory(:translation)
  end

  describe "a user is not logged in" do
    controller_actions.each do |action,req|
      if %w().include?(action)
        it "should reach the #{action} page" do
          send("#{req}", "#{action}", :id => @translation.id)
          response.redirect_url.should_not eq(login_url)
        end
      else
        it "should not reach the #{action} page" do
          send("#{req}", "#{action}", :id => @translation.id)
          response.redirect_url.should eq(login_url)
        end
      end
    end
  end

  describe "an admin is logged in" do
    before(:each) do
      @user = Factory(:user)
      session[:user_id] = @user.id
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
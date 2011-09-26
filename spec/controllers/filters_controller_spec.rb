require 'spec_helper'

describe Procmail::FiltersController do
  controller_actions = controller_actions("procmail/filters")

  before(:each){ @filter = Factory(:filter) }
 
  describe "a user is not logged in" do
    controller_actions.each do |action,req|
      it "should not reach the #{action} page" do
        send("#{req}", "#{action}", :id => @filter.id) 
        response.redirect_url.should eq(login_url)
      end
    end
  end

  describe "a member is logged in" do
    before(:each) do
      @user = Factory(:user, :roles_mask => 4)
      #login_with_user(@user)
      session[:username] = @user.username
    end

    controller_actions.each do |action,req|
      if %w(show edit update destroy).include? action
        it "should list the filters if id is wrong for #{action}" do
          send("#{req}", "#{action}", :id => 666) 
          response.redirect_url.should eq procmail_filters_url 
        end
      end
    end

    controller_actions.each do |action,req|
      if %w(index new create).include? action
        it "should reach the #{action} page" do
          send("#{req}", "#{action}", :id => @filter.id) 
          response.redirect_url.should_not eq(welcome_url)
        end
      elsif %w(edit update destroy show).include? action
        it "should reach one's own #{action} page" do
          own = Factory(:filter, :user_id => @user.id) 
          send("#{req}", "#{action}", :id => own.id) 
          response.redirect_url.should_not eq(welcome_url)
        end
        it "should not reach someone else's #{action} page" do
          own = Factory(:filter, :user_id => @user.id) 
          send("#{req}", "#{action}", :id => @filter.id) 
          response.redirect_url.should eq(welcome_url)
        end
      end
    end
  end

  describe "an admin is logged in" do
    before(:each) do
      user = Factory(:user, :roles_mask => 2)
      session[:username] = user.username
    end

    controller_actions.each do |action,req|
      it "should reach the #{action} page" do
        send("#{req}", "#{action}", :id => @filter.id) 
        response.redirect_url.should_not eq(welcome_url)
      end
    end
  end
end

require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do
  fixtures :all
  render_views

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when authentication is invalid" do
    User.stubs(:authenticate).returns(nil)
    post :create
    response.should render_template(:new)
    session['user_id'].should be_nil
  end

  it "create action should redirect when authentication is valid" do
    User.stubs(:authenticate).returns(User.first)
    post :create
    response.should redirect_to(translations_url)
    session['user_id'].should == User.first.id
  end

  describe "actions" do
    controller_actions = controller_actions("sessions")

    describe "a user is not logged in" do
      controller_actions.each do |action,req|
        if %w(new create destroy).include?(action)
          it "should reach the #{action} page" do
            send("#{req}", "#{action}")
            response.redirect_url.should_not eq(login_url)
          end
        else
          it "should not reach the #{action} page" do
            send("#{req}", "#{action}")
            response.redirect_url.should eq(login_url)
          end
        end
      end
    end

    describe "an admin is logged in" do
      before(:each) do
        @own = Factory(:user)
        session[:user_id] = @own.id
      end
      
      controller_actions.each do |action,req|
        if %w(new create destroy).include?(action)
          it "should reach the #{action} page" do
            send("#{req}", "#{action}")
            response.redirect_url.should_not eq(welcome_url)
          end
        else
          it "should not reach the #{action} page" do
            send("#{req}", "#{action}", :id => @own.id)
            response.redirect_url.should eq(welcome_url)
          end
        end
      end    
    end
  end
end

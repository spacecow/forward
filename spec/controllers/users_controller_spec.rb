require File.dirname(__FILE__) + '/../spec_helper'


describe UsersController do
  fixtures :all
  render_views

  it "edit action should redirect when not logged in" do
    get :edit, :id => "ignored"
    response.should redirect_to(login_url)
  end

  it "update action should redirect when not logged in" do
    put :update, :id => "ignored"
    response.should redirect_to(login_url)
  end

  it "update action should redirect when user is valid" do
    @controller.stubs(:current_user).returns(User.first)
    User.any_instance.stubs(:valid?).returns(true)
    put :update, :id => "ignored"
    response.should redirect_to(root_url)
  end

  describe "actions" do
    controller_actions = controller_actions("users")

    before(:each) do
      @user = Factory(:user)
    end

    describe "a user is not logged in" do
      controller_actions.each do |action,req|
        if %w().include?(action)
          it "should reach the #{action} page" do
            send("#{req}", "#{action}", :id => @user.id)
            response.redirect_url.should_not eq(login_url)
          end
        else
          it "should not reach the #{action} page" do
            send("#{req}", "#{action}", :id => @user.id)
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
        if %w(edit update).include?(action)
          it "should reach the #{action} for another user page" do
            send("#{req}", "#{action}", :id => @user.id)
            response.redirect_url.should_not eq(welcome_url)
          end
          it "should reach the #{action} for own user page" do
            send("#{req}", "#{action}", :id => @own.id)
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

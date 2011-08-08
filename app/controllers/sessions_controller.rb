class SessionsController < ApplicationController
  def new
  end

  def create
    if params[:username].blank? || params[:password].blank?
      flash[:alert] = alert2(:incorrect,t('messages.or',:obj1=>ft(:username),:obj2=>ftd(:password)))
      redirect_to login_path and return
    end
    if authpam(params[:username],params[:password])
      session[:username] = params[:username]
      session[:password] = params[:password]
      unless User.find_by_username(session[:username])
        User.create(:username => session[:username], :password => session[:password]) 
      end
      redirect_to edit_path, :notice => notify(:logged_in)
    else
      redirect_to login_path, :alert => alert2(:incorrect,
        t('messages.or',:obj1=>ft(:username),:obj2=>ftd(:password)))
    end

#    if user
#      session[:user_id] = user.id
#      redirect_to translations_path, :notice => "Logged in successfully."
#    else
#      flash.now[:alert] = "Invalid login or password."
#      render :action => 'new'
#    end
  end

  def destroy
    session[:username] = nil
    session[:password] = nil
    redirect_to login_path, :notice => notify(:logged_out)

#    session[:user_id] = nil
#    redirect_to root_url, :notice => "You have been logged out."
  end

  private

    def authpam(user,pass); pass == "correct" ? true : false end
end

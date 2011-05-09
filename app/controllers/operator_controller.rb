# -*- coding: utf-8 -*-

class OperatorController < ApplicationController
  def login
  end

  def logout
    session[:username] = nil
    redirect_to login_path, :notice => notify(:logged_out)
  end
  
  def connect
    if authpam(params[:username],params[:password])
      session[:username] = params[:username]
      redirect_to edit_path, :notice => notify(:logged_in)
    else
      redirect_to login_path, :alert => alert2(:incorrect,
        t('message.or',:obj1=>ft(:username),:obj2=>ftd(:password)))
    end
  end

  def edit
    if session[:username]
      p "no redirect"
      p hejsan
    else
      redirect_to login_path, :alert => alert(:unauthorized_access)
    end
  end

  def update
    redirect_to edit_path
  end

  def hejsan; "dasan" end
  
  private
    def authpam(user,pass); pass == "correct" ? true : false end
end


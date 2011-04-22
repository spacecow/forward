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
    redirect_to login_path, :alert => alert(:unauthorized_access) if session[:username].nil?
  end

  def update
    p params
    redirect_to edit_path
  end
  
  private
    def authpam(user,pass); pass == "correct" ? true : false end
end


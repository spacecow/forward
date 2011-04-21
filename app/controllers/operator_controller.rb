# -*- coding: utf-8 -*-
#require 'net/ssh'

class OperatorController < ApplicationController
  def login
  end

  def logout
    session[:username] = nil
    redirect_to login_path
  end
  
  def connect
    if authpam(params[:username],params[:password])
      session[:username] = params[:username]
      redirect_to edit_path
    else
      redirect_to login_path, :alert => "Username or password incorrect."
    end
  end

  def edit
    redirect_to login_path, :alert => "Unauthorized access." if session[:username].nil?
  end
end

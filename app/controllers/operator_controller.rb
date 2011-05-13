# -*- coding: utf-8 -*-
#require 'rpam'

class OperatorController < ApplicationController
  #include Rpam

  def login
  end

  def logout
    session[:username] = nil
    redirect_to login_path, :notice => notify(:logged_out)
  end
  
  def connect
    if authpam(params[:username],params[:password])
      session[:username] = params[:username]
      session[:password] = params[:password]
      redirect_to edit_path, :notice => notify(:logged_in)
    else
      redirect_to login_path, :alert => alert2(:incorrect,
        t('message.or',:obj1=>ft(:username),:obj2=>ftd(:password)))
    end
  end

  def edit
    if session[:username]
      IO.popen("/usr/local/sbin/chfwd -g #{session[:username]}", 'r+') do |pipe|
        pipe.write(session[:password])
        pipe.close_write
        @input = convert_in(pipe.read) 
      end
    else
      redirect_to login_path, :alert => alert(:unauthorized_access)
    end
  end

  def update
    IO.popen("/usr/local/sbin/chfwd -s #{session[:username]}", 'r+') do |pipe|
      pipe.write(session[:password])
      pipe.write params[:address1]
      pipe.write params[:address2]
      pipe.write params[:address3]
      pipe.write params[:address4]
      pipe.write params[:address5]
      pipe.close_write
    end
    redirect_to edit_path
  end

  private
    def authpam(user,pass); pass == "correct" ? true : false end
    def convert_in(s)
      ret = []
      s.split("\n").each do |add|
        ret << {:address => add.chomp}
      end
      (5-ret.size).times do |add|
        ret << {:address => nil}
      end
      ret
    end
end


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
    p params
    IO.popen("/usr/local/sbin/chfwd -s #{session[:username]}", 'r+') do |pipe|
      pipe.write "#{session[:password]}\n"
      pipe.write "\\#{session[:username]}\n" if params[:keep] == "yes"
      pipe.write "#{params[:address1]}\n" if params[:address1]
      pipe.write "#{params[:address2]}\n" if params[:address2]
      pipe.write "#{params[:address3]}\n" if params[:address3]
      pipe.write "#{params[:address4]}\n" if params[:address4]
      pipe.write "#{params[:address5]}\n" if params[:address5]
      pipe.close_write
    end
    redirect_to edit_path
  end

  private
    def authpam(user,pass); pass == "correct" ? true : false end
    def convert_in(s)
      ret = []
      adds = s.split("\n")
      keep = adds.shift if adds[0][0] == "\\"
      adds.each do |add|
        ret << {:address => add.chomp}
      end
      (5-ret.size).times do |add|
        ret << {:address => nil}
      end
      ret << {:keep => !keep.nil?}
    end
end


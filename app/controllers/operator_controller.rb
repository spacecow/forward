# -*- coding: utf-8 -*-
#require 'rpam'

class OperatorController < ApplicationController
  #include Rpam

  def login
  end

  def logout
    session[:username] = nil
    session[:password] = nil
    redirect_to login_path, :notice => notify(:logged_out)
  end
  
  def connect
    if params[:username].blank? || params[:password].blank?
      flash[:alert] = alert2(:incorrect,t('message.or',:obj1=>ft(:username),:obj2=>ftd(:password)))
      redirect_to login_path and return
    end
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
      pipe.write "#{session[:password]}\n"
      pipe.write "\\#{session[:username]}\n" if params[:keep] == "yes"
      pipe.write "#{params[:address1]}\n" if params[:address1].present?
      pipe.write "#{params[:address2]}\n" if params[:address2].present?
      pipe.write "#{params[:address3]}\n" if params[:address3].present?
      pipe.write "#{params[:address4]}\n" if params[:address4].present?
      pipe.write "#{params[:address5]}\n" if params[:address5].present?
      pipe.close_write
    end
    flash[:notice] = updated(:forwarding_address)
    redirect_to edit_path
  end

  private
    def authpam(user,pass); pass == "correct" ? true : false end
    def convert_in(s)
      ret = []
      adds = s.split("\n").map{|line| line.split(',').map(&:strip)}.flatten
      keep = nil
      adds.each_with_index do |add,i|
        keep = adds.delete_at(i) if add[0] == "\\"
      end
      adds.each do |add|
        ret << {:address => add.chomp}
      end
      (5-ret.size).times do |add|
        ret << {:address => nil}
      end
      ret << {:keep => !keep.nil?}
    end
end


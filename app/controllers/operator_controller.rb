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
      flash[:alert] = alert2(:incorrect,t('messages.or',:obj1=>ft(:username),:obj2=>ftd(:password)))
      redirect_to login_path and return
    end
    if authpam(params[:username],params[:password])
      session[:username] = params[:username]
      session[:password] = params[:password]
      redirect_to forward_edit_path, :notice => notify(:logged_in)
    else
      redirect_to login_path, :alert => alert2(:incorrect,
        t('messages.or',:obj1=>ft(:username),:obj2=>ftd(:password)))
    end
  end

  def edit
    if session[:username]
      if params[:address]
        if params[:commit] == add(:address_field)
          @input = params[:address].merge({ params[:address].keys.reject{|e| e=="keep"}.length.to_s => ""})
        else
          @input = params[:address]
        end
      else
        IO.popen("/usr/local/sbin/chfwd -g #{session[:username]}", 'r+') do |pipe|
          pipe.write(session[:password])
          pipe.close_write
          @input = convert_in(pipe.read) 
        end
      end
    else
      redirect_to login_path, :alert => alert(:unauthorized_access)
    end
  end

  def update
    if params[:commit] == add(:address_field)
      flash[:notice] = added(:address_field)
      redirect_to forward_edit_path(:commit => add(:address_field), :no => address_field_no, :address => params[:address])
    else
      IO.popen("/usr/local/sbin/chfwd -s #{session[:username]}", 'r+') do |pipe|
        pipe.write "#{session[:password]}\n"
        pipe.write "\\#{session[:username]}\n" if params["address"]["keep"] == "yes"
        pipe.write "#{params[:address].values.reject{|e| e.blank? || e=="yes"}.join("\n")}\n"
        pipe.close_write
      end
      flash[:notice] = updated(:forwarding_address)
      redirect_to forward_edit_path
    end
  end

  def procmail
    @filter = Filter.new
    @filter.rules.build
    @filter.actions.build
  end

  private
    def address_field_no; params[:address].length end
    def authpam(user,pass); pass == "correct" ? true : false end
    def convert_in(s,d=5)
      ret = {} 
      adds = s.split("\n").map{|line| line.split(',').map(&:strip)}.flatten
      keep = nil
      adds.each_with_index do |add,i|
        keep = adds.delete_at(i) if add[0] == "\\"
      end
      adds.each_with_index do |add,i|
        ret[i.to_s] = add.chomp
      end
      (d-adds.length).times do |i|
        ret[(i+adds.length).to_s] = ""
      end
      ret["keep"] = keep.nil? ? nil : "yes"
      ret
    end
    def inc_address_field_no; params[:no].to_i+1 end
end

# -*- coding: utf-8 -*-
#require 'net/ssh'

class OperatorController < ApplicationController
  def login
  end

  def connect
# require ‘rubygems’
# require ‘net/ssh’

# username=”yourusername”
# hostnames=["node01","node02"]
# script=”date;uptime;”

# hostnames.each {|hostname|
# Net::SSH.start( hostname, username ) do |session|
# session.open_channel do |channel|
# channel.on_data { |chan,output| puts “#{output.inspect}” }
# channel.on_extended_data { |chan,type,output| print output }
# channel.exec script
# end
# session.loop
    # end
#     hostname = "www.riec.tohoku.ac.jp"
#     session[:connection] =
#       Net::SSH.start(hostname, params[:username], :password => params[:password])
# #    session[:connection].loop {true}
#     redirect_to operator_login_path(:test => session[:connection].exec!("hostname"))
  end
end

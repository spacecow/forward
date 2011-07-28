class Procmail::FiltersController < ApplicationController
  include Procmail

  def new
    @filter = Filter.new
    @filter.rules.build
    @filter.actions.build
  end

  def index
    IO.popen("/usr/local/sbin/chprocmailrc -g #{session[:username]}", 'r+') do |pipe|
      pipe.write(session[:password])
      pipe.close_write
      @filters = load_filters(pipe.read).map(&:rules) 
    end
  end

  private

    def load_procmailrc(s)
      s.split("\n").each do |line|
        p line if line =~ /^:0/
      end
    end
end

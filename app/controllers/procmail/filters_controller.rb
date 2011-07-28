class Procmail::FiltersController < ApplicationController
  def new
    @filter = Filter.new
    @filter.rules.build
    @filter.actions.build
  end

  def index
    IO.popen("/usr/local/sbin/chprocmailrc -g #{session[:username]}", 'r+') do |pipe|
      pipe.write(session[:password])
      pipe.close_write
      @input = load_procmailrc(pipe.read) 
    end
  end

  private

    def load_procmailrc(s)
      s.split("\n").each do |line|
        p line if line =~ /^:0/
      end
    end
end

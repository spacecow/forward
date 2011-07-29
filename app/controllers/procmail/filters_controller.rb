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
      @filters = load_filters(pipe.read)
    end
  end

  def edit
    @filter = Filter.find(params[:id])
  end

  def update
    @filter = Filter.find(params[:id])
    if params[:commit] == "+"
      @filter.rules.create
      redirect_to edit_procmail_filter_path(@filter) and return
    end
    if @filter.update_attributes(params[:filter])
      redirect_to procmail_filters_path
    else
    end
  end

  private

    def load_procmailrc(s)
      s.split("\n").each do |line|
        p line if line =~ /^:0/
      end
    end
end

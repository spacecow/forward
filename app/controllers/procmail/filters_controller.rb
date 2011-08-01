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
    build_non_saved_rules
    build_added_rule
  end

  def update
    @filter = Filter.find(params[:id])
    if params[:commit] == "+"
      redirect_to edit_procmail_filter_path(@filter, :rules => params[:filter][:rules_attributes], :add_rule => true) and return
    end
    if @filter.update_attributes(params[:filter])
      redirect_to procmail_filters_path
    else
    end
  end

  private

    def build_added_rule; @filter.rules.build if params[:add_rule] end
    def build_non_saved_rules
      if params[:rules] 
        params[:rules].each do |key,value|
          @filter.rules.build if value[:id].nil?
        end
      end
    end

    def load_procmailrc(s)
      s.split("\n").each do |line|
        p line if line =~ /^:0/
      end
    end
end

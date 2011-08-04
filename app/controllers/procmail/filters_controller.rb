class Procmail::FiltersController < ApplicationController
  include Procmail

  before_filter :build_user_filter_with_params, :only => :create
  load_and_authorize_resource

  def show
  end

  def index
    prepare_filters(session[:username], session[:password])
  end

  def new
    @filter.rules.build
    @filter.actions.build
  end

  def create
    if @filter.save
      save_filters(session[:username], session[:password], current_user.filters)
      redirect_to procmail_filters_path
    else
      render :new
    end
  end

  def edit
    build_non_saved_rules
    build_added_rule
    build_non_saved_actions
    build_added_action
  end

  def update
    if params[:rule_plus]
      redirect_to edit_procmail_filter_path(@filter, :rules => params[:filter][:rules_attributes], :actions => params[:filter][:actions_attributes], :add_rule => true) and return
    elsif params[:action_plus]
      redirect_to edit_procmail_filter_path(@filter, :rules => params[:filter][:rules_attributes], :actions => params[:filter][:actions_attributes], :add_action => true) and return
    end
    if @filter.update_attributes(params[:filter])
      save_filters(session[:username], session[:password], current_user.filters)
      redirect_to procmail_filters_path
    end
  end

  def destroy
    redirect_to procmail_filters_path
  end

  private

    def build_added_action; @filter.actions.build if params[:add_action] end
    def build_added_rule; @filter.rules.build if params[:add_rule] end
    def build_non_saved_associations(assoc)
      if params[assoc] 
        params[assoc].each do |key,value|
          @filter.send(assoc).build(value) if value[:id].nil?
        end
      end
    end
    def build_non_saved_actions; build_non_saved_associations(:actions) end
    def build_non_saved_rules; build_non_saved_associations(:rules) end
    def build_user_filter_with_params; @filter = current_user.filters.build(params[:filter]) end
end

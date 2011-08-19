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
    if params[:rule_plus] or params[:action_plus]
      build_non_saved_rules
      build_added_rule
      build_non_saved_actions
      build_added_action
      render :new and return
    end
    if @filter.save
      save_filters(session[:username], session[:password], current_user.filters)
      redirect_to procmail_filters_path
    else
      build_non_saved_rules
      build_non_saved_actions
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
    if params[:rule_plus] or params[:action_plus]
      build_non_saved_rules
      build_added_rule
      build_non_saved_actions
      build_added_action
      render :edit and return
    end
    p @filter.actions
    if @filter.update_attributes(params[:filter])
      save_filters(session[:username], session[:password], current_user.filters)
      redirect_to procmail_filters_path
    else
      if @filter.actions.map(&:valid?).reject{|e| e==false}.empty?
        render :edit
      else
        @filter.actions.reject!{|e| !e.valid?}
        p @filter.actions
        redirect_to procmail_filters_path
      end
    end
  end

  def destroy
    redirect_to procmail_filters_path
  end

  private

    def build_added_action; @filter.actions.build if params[:action_plus] end
    def build_added_rule; @filter.rules.build if params[:rule_plus] end
    def build_non_saved_associations(assoc)
      if params["filter"] && params["filter"]["#{assoc}_attributes"] 
        params["filter"]["#{assoc}_attributes"].each do |key,value|
          @filter.send(assoc).build(value) if value[:id].nil?
        end
      end
    end
    def build_non_saved_actions; build_non_saved_associations(:actions) end
    def build_non_saved_rules; build_non_saved_associations(:rules) end
    def build_user_filter_with_params; @filter = current_user.filters.build(params[:filter]) end
end

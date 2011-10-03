class Procmail::FiltersController < ApplicationController
  include Forwarding
  include Procmail

  before_filter :build_user_filter_with_params, :only => :create
  before_filter :check_existence_of_filter, :only => [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  def show
    redirect_to edit_procmail_filter_path(@filter)
  end

  def deliver_error(e)
    @error = "You have encounted an error.<br><br>#{e}<br><br>The administrator has been informed.<br>Please wait while the problem is being resolved."
    ErrorMailer.filter_error(session[:username],e).deliver
  end

  def index
    redirect_to new_procmail_filter_path and return if params[:filter].present?
    begin
      prepare_filters(session[:username], session[:password])
    rescue Exception => e
      deliver_error(e)
    end
    session[:prolog] = "#{@prolog.join("\n")}" if @prolog
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @filters }
    end
  end

  def new
    @filter.rules.build
    @filter.actions.build
  end

  def create
    redirect_to procmail_filters_path and return if params[:cancel] 
    if params[:rule_plus] or params[:action_plus]
      build_added_rule
      build_added_action
      render :new and return
    end
    delete_button = params.keys.select{|e| e.match(/minus/)}.join
    if delete_button.present?
      delete_attr = delete_button.split('_')[0]
      delete_index = delete_button.split('_')[-1].to_i
      if delete_attr == "rule"
        @filter.rules.delete_at(delete_index)
      else
        @filter.actions.delete_at(delete_index)
      end
      @filter.rules.build if @filter.rules.empty?
      @filter.actions.build if @filter.actions.empty?
      render :edit and return
    end

    @filter.actions.inspect
    if @filter.save
      save_filters(session[:username], session[:password], session[:prolog], current_user.filters)
      update_forwards(session[:username], session[:password])
      redirect_to procmail_filters_path, :notice => created(:filter)
    elsif @filter.rules.map(&:valid?).reject{|e| e==false}.empty?
      @filter.rules.build if @filter.rules.empty?
      @filter.actions.build if @filter.actions.empty?
      render :new
    elsif @filter.actions.map(&:valid?).reject{|e| e==false}.empty?
      @filter.rules.build if @filter.rules.empty?
      @filter.actions.build if @filter.actions.empty?
      render :new
    else
      @filter.rules.reject!{|e| !e.valid?}
      @filter.actions.reject!{|e| !e.valid?}
      @filter.save
      save_filters(session[:username], session[:password], session[:prolog], current_user.filters)
      update_forwards(session[:username], session[:password])
      flash[:notice] = "Created rules: #{@filter.rules.count}, actions: #{@filter.actions.count}"
      redirect_to procmail_filters_path
    end
  end

  def edit
    build_non_saved_rules
    build_added_rule
    build_non_saved_actions
    build_added_action
  end

  def update
    redirect_to procmail_filters_path and return if params[:cancel] 
    @filter.actions.inspect
    @filter.attributes = params[:filter]
    if params[:rule_plus] or params[:action_plus]
      build_added_rule
      build_added_action
      render :edit and return
    end
    delete_button = params.keys.select{|e| e.match(/minus/)}.join
    if delete_button.present?
      delete_attr = delete_button.split('_')[0]
      delete_index = delete_button.split('_')[-1]
      if delete_attr == "rule"
        delete_rule = params[:filter][:rules_attributes].delete(delete_index)
        @filter.rules.delete_at(delete_index.to_i)
        Rule.find(delete_rule[:id].to_i).destroy if delete_rule[:id]
      else
        delete_action = params[:filter][:actions_attributes].delete(delete_index)
        @filter.actions.delete_at(delete_index.to_i)
        Action.find(delete_action[:id].to_i).destroy if delete_action[:id]
      end
      @filter.rules.build if @filter.rules.empty?
      @filter.actions.build if @filter.actions.empty?
      render :edit and return
    end
    
    if @filter.save 
      #@filter.update_attributes(params[:filter])
      filter = Filter.find(params[:id])
      if filter.rules.empty? || filter.actions.empty? 
        filter.destroy
        flash[:notice] = removed(:filter)
      end
      save_filters(session[:username], session[:password], session[:prolog], current_user.filters)
      redirect_to procmail_filters_path
    else
      if @filter.actions.map(&:valid?).reject{|e| e==false}.empty?
        render :edit
      elsif @filter.rules.map(&:valid?).reject{|e| e==false}.empty?
        render :edit
      else
        @filter.actions.reject!{|e| !e.valid?}
        @filter.rules.reject!{|e| !e.valid?}
        @filter.save
        save_filters(session[:username], session[:password], session[:prolog], current_user.filters)
        flash[:notice] = "Updated rules: #{@filter.rules.count}, actions: #{@filter.actions.count}"
        redirect_to procmail_filters_path
      end
    end
  end

  def destroy
    @filter.destroy
    save_filters(session[:username], session[:password], session[:prolog], current_user.filters)
    redirect_to procmail_filters_path
  end

  private

    def build_added_action; @filter.actions.build if params[:action_plus] end
    def build_added_rule; @filter.rules.build if params[:rule_plus] end
    def build_non_saved_associations(assoc)
      if params["filter"] && params["filter"]["#{assoc}_attributes"] 
        params["filter"]["#{assoc}_attributes"].each do |key,value|
          if value[:id].nil?
            @filter.send(assoc).build(value)
          else
            @filter.send(assoc).select{|e| e.id==key.to_i}
          end
        end
      end
    end
    def build_non_saved_actions; build_non_saved_associations(:actions) end
    def build_non_saved_rules; build_non_saved_associations(:rules) end
    def build_user_filter_with_params; @filter = current_user.filters.build(params[:filter]) if current_user end

    def check_existence_of_filter
      redirect_to procmail_filters_path and return unless Filter.exists?(params[:id])
    end
end

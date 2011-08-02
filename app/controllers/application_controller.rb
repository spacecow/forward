class ApplicationController < ActionController::Base
  include ControllerAuthentication
  rescue_from CanCan::AccessDenied do |exception|
    if current_user
      redirect_to welcome_url, :alert => exception.message
    else
      redirect_to login_url, :alert => exception.message
    end
  end
  protect_from_forgery
  before_filter :set_language
  helper_method :add, :t2, :lbl, :chain, :current_user, :english?, :ft

  def add(s); t2(:add,s) end
  def chain(s1,s2); "#{s1.to_s}.#{s2.to_s}" end
  def lbl(s); chain(:label,s) end
  def t2(s1,s2); t(lbl(s1), :obj => t(s2)) end

  def added(s); success(:added,s) end
  def alert(act); t("alert.#{act}") end
  def alert2(act,obj); t("alert.#{act}",:obj=>obj) end
  def created(s); success(:created,s) end
  def deleted(s); success(:deleted,s) end
  def d(s); t(s).downcase end
  def dp(s); pl(s).downcase end
  def english?; I18n.locale == :en end
  def ft(s); t("formtastic.labels.#{s.to_s}") end
  def ftd(s); d("formtastic.labels.#{s.to_s}") end  
  def notify(act); t("notice.#{act}") end
  def pl(s); t(s).match(/\w/) ? t(s).pluralize : t(s) end  
  def success(act,mdl); t("success.#{act}",:obj=>d(mdl)) end
  def success_p(act,mdl); t("success.#{act}",:obj=>dp(mdl)) end
  def success_p(act,owner,mdl); t("success.#{act}",:obj=>t(:possessive,:owner=>owner,:obj=>dp(mdl))) end
  def updated(s); success(:updated,s) end
  def updated_p(s); success_p(:updated,s) end
  def updated_p(s1,s2); success_p(:updated,s1,s2) end

  private

    def current_user
      if session[:username]
        @current_user ||= User.find_by_username(session[:username])
        if !@current_user
          @current_user = User.create(:username => session[:username], :password => session[:password]) 
        end  
        @current_user
      end
    end
    
    def current_user_name; current_user && current_user.name end
    def current_user_email; current_user && current_user.email end
    def current_user_affiliation; current_user && current_user.affiliation end
    
    def set_language
      session[:language] = params[:language].to_sym if params[:language]
      I18n.locale = session[:language] || I18n.default_locale
    end
end

class TranslationsController < ApplicationController
  def index
    @translation = Translation.new
    @translations = $redis 
    @locales = Locale.all
  end

  def create
    @translation = Translation.new(params[:translation])
    if @translation.save
      locale = Locale.find(params[:translation][:locale])
      I18n.backend.store_translations(locale.title, {params[:translation][:key] => params[:translation][:value]}, :escape => false)
      redirect_to translations_url, :notice => added(:translation)
    else
      @translations = $redis
      @locales = Locale.all
      render :index
    end
  end
end

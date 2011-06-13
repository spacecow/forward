class TranslationsController < ApplicationController
  def index
    @translation = params[:key].blank? ? Translation.new : Translation.new.initialize_from_redis(params[:key])
    @translations = $redis 
    @locales = Locale.all
  end

  def create
    @translation = Translation.new(params[:translation])
    if @translation.valid?
      locale = @translation.locale
      I18n.backend.store_translations(@translation.locale.title, {@translation.key => @translation.value}, :escape => false)
      redirect_to translations_url, :notice => added(:translation)
    else
      @translations = $redis
      @locales = Locale.all
      render :index
    end
  end

  def delete
    $redis.del(params[:key])
    redirect_to translations_path
  end
end

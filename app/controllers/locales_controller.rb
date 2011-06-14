class LocalesController < ApplicationController
  load_and_authorize_resource

  def create
    if @locale.save
      redirect_to translations_path, :notice => created(:locale)
    else
      @translation = Translation.new
      @translations = $redis 
      @locales = Locale.all
      render '/translations/index'
    end
  end

  def update
  end
end

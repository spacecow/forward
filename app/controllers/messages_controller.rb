class MessagesController < ApplicationController
  before_filter :build_user_message, :only => :new
  before_filter :build_user_message_with_params, :only => :create
  load_and_authorize_resource
  
  def new
  end

  def create
    if @message.save
      flash[:notice] = notify(:message_sent) 
      redirect_to forward_edit_path
    else
      render :new
    end
  end

  private

    def build_user_message
      @message = current_user.messages.build
    end
    def build_user_message_with_params
      @message = current_user.messages.build(params[:message])
    end
end

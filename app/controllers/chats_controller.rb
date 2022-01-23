class ChatsController < ApplicationController
  def create
    @chat = Chat.get(current_user.id, params[:user_id])
    
    add_to_chats unless conversated?

    respond_to do |format|
      format.js
    end
  end

  def index
    session[:chats] ||= []
    @users = User.all.where.not(id: current_user.id)
    @chats = Chat.includes(:recipient, :messages).find(session[:chats])
  end

  def close
    @chat = Chat.find(params[:id])

    session[:chats].delete(@chat.id)

    respond_to do |format|
      format.js
    end
  end

  private

  def add_to_chats
    session[:chats] ||= []
    session[:chats] << @chats.id
  end

  def conversated?
    session[:chats].include?(@chat.id)
  end
end

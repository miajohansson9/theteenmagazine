class MessagesController < ApplicationController
  def create
    @chat = Chat.includes(:recipient).find(params[:chat_id])
    @message = @chat.messages.create(message_params)

    respond_to do |format|
        format.js
    end
  end

  private

  def message_params
    params.require(:message).permit(:user_id, :body)
  end
end

class MessagesController < ApplicationController
  before_action :set_conversation
  def create
    @user = current_user
    @user.reply_to_conversation(
     @conversation,
     params[:mailboxer_message][:body],
     nil,
     true,
     true,
     params[:mailboxer_message][:attachment]
     )
     
     MessageRelayJob.perform_later(@conversation)
  end
  
  private
  
    def self.render_message(message)
     render :partial => 'messages/message', :locals => { receipt: message }
    end
  def set_conversation
    @conversation = current_user.mailbox.conversations.find(params[:conversation_id])
  end
end
class ConversationsController < ApplicationController
  def index
    @user = current_user
    @conversations = current_user.mailbox.conversations
  end

  def inbox
    @conversations = current_user.mailbox.inbox
    render action: :index
  end

  def sent
    @conversations = current_user.mailbox.sentbox
    render action: :index
  end

  def trash
    @conversations = current_user.mailbox.trash
    render action: :index
  end

  def show
    @user = current_user
    @conversations = current_user.mailbox.conversations
    @conversation = current_user.mailbox.conversations.find(params[:id])
    @conversation.mark_as_read(current_user)
    @message = Mailboxer::Message.new
  end
  
  def user_message
    @user = current_user
    @conversations = current_user.mailbox.conversations
    @conversation = Mailboxer::Conversation.new
    @user = User.friendly.find(params[:user_id])
  end 
 
  def new
    @user = current_user
    @conversations = current_user.mailbox.conversations
    @conversation = Mailboxer::Conversation.new
    @recipients = User.all - [current_user]
  end

  def create
    recipients = User.where(id: params[:user_ids])
    receipt   = current_user.send_message(recipients, params[:body], params[:subject])
    redirect_to conversation_path(receipt.conversation)
  end
end
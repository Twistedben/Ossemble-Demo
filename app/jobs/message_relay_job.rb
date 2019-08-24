class MessageRelayJob < ApplicationJob
  queue_as :default
  

    
  def perform(message)
    ActionCable.server.broadcast "conversations:#{message.id}", {
      message: MessagesController.render_message(message),
      adminname: admin_message.admin.name,
      body: admin_message.body,
      conversation_id: message.id
      }

  end
  
  private
  
  
end

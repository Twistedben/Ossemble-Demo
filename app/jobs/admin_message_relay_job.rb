class AdminMessageRelayJob < ApplicationJob
  queue_as :default

  def perform(admin_message)
    ActionCable.server.broadcast "admin_chatrooms:#{admin_message.admin_chatroom.id}", {
      admin_name:    admin_message.admin.name,
      admin_message: admin_message.body,
      admin_chatroom_id: admin_message.admin_chatroom.id
    }
  end
end

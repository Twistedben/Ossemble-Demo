#class AdminChatroomsChannel < ApplicationCable::Channel
#
# def subscribed
#   current_admin.admin_chatrooms.each do |chatroom|
#     stream_from "admin_chatrooms:#{chatroom.id}"
#   end
# end

# def unsubscribed
#   stop_all_streams
# end

# def send_message(data)
#   @chatroom =      AdminChatroom.find(data["admin_chatroom_id"])
#   admin_message   = @chatroom.admin_messages.create(body: data["body"], admin: current_admin)
#   AdminMessageRelayJob.perform_later(admin_message)
# end
#nd

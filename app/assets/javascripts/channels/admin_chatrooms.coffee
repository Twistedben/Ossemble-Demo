#App.admin_chatrooms = App.cable.subscriptions.create "AdminChatroomsChannel",
#  connected: ->
#    # Called when the subscription is ready for use on the server
#    
#    
#  disconnected: ->
#    # Called when the subscription has been terminated by the server
#
#  received: (data) ->
#    $("[data-behavior='messages'][data-chatroom-id='#{data.admin_chatroom_id}'").append(data.admin_message)
#    
#    if document.hidden && Notification.permission == "granted"
#      new Notification("New Message", {body: "You have received a new message in a chatroom."})
#  
#  send_message: (admin_chatroom_id, admin_message) ->
#    @perform "send_message", {admin_chatroom_id: admin_chatroom_id, body: admin_message}
#    
#
#    # Called when there's incoming data on the websocket for this channel

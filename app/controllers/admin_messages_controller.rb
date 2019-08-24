class AdminMessagesController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_chatroom

  def create
    @message = @chatroom.admin_messages.new(message_params)
    @message.admin = current_admin
    if @message.save
      redirect_to request.referrer
    # Below - TODO: Commented out for now to do a refresh instead. This is a hack araound for chat on production until ActionCable behaves in production.
        #ActionCable.server.broadcast "admin_chatrooms:#{@message.admin_chatroom.id}", {
       #   admin_message: render_message(@message),
      #    admin_chatroom_id: @message.admin_chatroom.id
     #   }
    else 
      flash[:alert] = "Message can't be empty."
      redirect_to chatroom_path(@chatroom)
      
    end 
    
  end

  private
  
    def render_message(admin_message)
  #In the "message" partial, we use the object "message" and locals allows us to access that non-instance var
      render(admin_message)
    end
    
    def set_chatroom
      @chatroom = AdminChatroom.find(params[:chatroom_id])
    end

    def message_params
      params.require(:admin_message).permit(:body, :attachment)
    end
end 
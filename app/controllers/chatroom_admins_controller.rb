class ChatroomAdminsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_chatroom
  
  def create
    @chatroom_admin = @chatroom.chatroom_admins.where(admin_id: current_admin.id).first_or_create
    redirect_to chatrooms_path(@chatroom_admin)
  end  
  
  def destroy
    @chatroom_admin = @chatroom.chatroom_admins.where(admin_id: current_admin.id).destroy_all
    redirect_to chatrooms_path
  end
  
  private
  
    def set_chatroom
      @chatroom = AdminChatroom.find(params[:chatroom_id])
    end
end
class NotificationsController < ApplicationController
  before_action :set_institute   

  def index
    if current_user 
      @notifications = Notification.where(recipient: current_user).unread.limit(15)
      @read_notifications = Notification.where(recipient: current_user).read.limit(10)
    elsif current_admin 
      @notifications = Notification.where(recipient: current_admin).unread.limit(15)
      @read_notifications = Notification.where(recipient: current_admin).read.limit(10)
      destroy_orphaned_notifications
    end 
  end
  
  def mark_as_read
    if current_user
      @notifications = Notification.where(recipient: current_user).unread
      @notifications.update_all(read_at: Time.zone.now)
      render json: {success: true}
    elsif current_admin
      @notifications = Notification.where(recipient: current_admin).unread
      @notifications.update_all(read_at: Time.zone.now)
      render json: {success: true}
    end
  end

  private
  
    # Below -  Destroys notifications that are Nil to prevent errors in notification page.
    def destroy_orphaned_notifications 
      if current_user
        @notifications = Notification.where(recipient: current_user)
      elsif current_admin
        @notifications = Notification.where(recipient: current_admin)
      end
      @notifications.each do |notification|
        notification.destroy if notification.notifiable.nil?
      end 
    end   
    
    def set_institute 
      if current_user 
        @institute = Institute.friendly.find(current_user.institute_id)
      elsif current_admin 
        @institute = Institute.friendly.find(current_admin.institute_id)
      end 
    end
    
end
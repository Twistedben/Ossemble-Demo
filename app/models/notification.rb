class Notification < ApplicationRecord

# Begin - Scopes for Complaints.
  # Below - Orders notifications by created at.
  default_scope { order(created_at: :desc)}
  # BElow -Scopes by where notifications are not read, determined by read_at being nil.
  scope :unread, ->{where read_at: nil}
  # Below - Scopes where notifications are read, determined by read_at not being nil
  scope :read, ->{where.not(read_at: nil)}
# End - Scopes
  belongs_to :recipient, class_name: 'Admin'
  belongs_to :actor, class_name: 'Admin'
  belongs_to :notifiable, polymorphic: true
  
  
  # Below -  Creates notification with arguments that are relevant to be passed in
  def create_notification(recipient, actor, action, notifiable)
    notification = Notification.create(recipient_id: recipient.id, actor_id: actor.id, action: action, notifiable: notifiable)
  end   
  
end

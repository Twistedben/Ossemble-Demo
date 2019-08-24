class AdminMessage < ApplicationRecord
  
  # Below - Plain validation of BLANK  
  validates :body, presence: { message: "Message can't be blank" }
  
  belongs_to :admin_chatroom
  belongs_to :admin
  has_one_attached :attachment, dependent: :destroy
  
  # Below - Allows Mentions inside admin messages of chatrooms
  def mentions
    @mentions ||= begin
                    regex = /@([\w]+\s[\w]+)/ 
                    body.scan(regex).flatten
                  end
  end
  
  def mentioned_admins
    mentioned_admins ||= Admin.where(name: mentions)
  end
  
  # Below - Callback that sends an email to mentioned admins after a message is sent.
  after_create :notify_admins
  
  # Below - Sends a email to notified admins in chatrooms, from Notification Mailer.
  def notify_admins
    mentioned_admins.each do |mentioned|
      NotificationMailer.mentioned_email(self.admin, mentioned, self.admin_chatroom).deliver_now
    end
  end
  
end

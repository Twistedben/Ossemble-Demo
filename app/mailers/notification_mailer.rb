class NotificationMailer < ApplicationMailer
  # Main Mailer Model for sending admins emails when mentioned in chatrooms. 
  
  # Below - Sending email for Complaint filed threshold being hit, CAC.
  def mentioned_email(sender, mentioned, chatroom)
    @sender    = sender
    @mentioned = mentioned
    @chatroom  = chatroom
    @url       = chatroom_url(chatroom)
    @workplace = chatroom.workplace.name
    mail(to: @mentioned.email, subject: "#{@sender.name} has mentioned you in the #{@chatroom.name} chatroom.")
  end
  
  
end

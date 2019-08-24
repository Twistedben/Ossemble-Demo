class AdminMailer < Devise::Mailer
  # Workplace invite is sent from this. (admins/mailer/workplace_invite.html.ern) THis comes from Workplace_Controller under create_member
    default from: 'support@ossemble.com'
    layout 'mailer'

    def new_user_waiting_for_approval(email)
      @email = email
      mail(to: 'admin@email.com', subject: 'New User Awaiting Admin Approval')
    end
    # Below - Mail for adding a non-existent user to workplace
    def new_workplace_invite(sender, invite, recipient_email, recipient_name, workplace, token, workplace_id)
      @sender          = sender
      @invite          = invite
      @recipient_email = recipient_email
      @recipient_name  = recipient_name
      @workplace       = workplace 
      @token           = token
      @workplace_id    = workplace_id
      mail(to: "#{@recipient_email}", subject: "#{@sender.name} invited you to join Ossemble")
    end 
    # Below - Mail for adding a non-existent user to workplace
    def existing_workplace_invite(sender, invite, recipient_email, recipient_name, workplace)
      @sender          = sender
      @invite          = invite
      @recipient_email = recipient_email
      @recipient_name  = recipient_name
      @workplace       = workplace 
      mail(to: "#{@recipient_email}", subject: "#{@sender.name} added you to an Ossemble Workplace")
    end 
    
end
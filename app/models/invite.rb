class Invite < ApplicationRecord
# Main Model for Invites being sent by admins to other admins to join workplaces.


# Begin - SCOPES: Scopes for records.
  # Below - Orders created to the top of the list in descending order.
  default_scope { order(created_at: :desc)}
  
# End - SCOPES: Scopes for records.

# Begin - Gems and acts_as setups. 

# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level, Uniqueness and Character Limitations.
  
  # Begin - CUSTOM VALIDATIONS: 
  
  # End - CUSTOM VALIDATIONS: 
  
  # Begin - RUBY VALIDATIONS: 
    # Below - Plain validation of first name  
    validates :email, presence: { message: 'Email to send invite to must be provided.' }
    # Below - Plain validation of first name  
    validates :first_name, presence: { message: 'First name of the person you intend to invite must be provided.' }
    # Below - Plain validation of last name  
    validates :last_name, presence: { message: 'Last name of the person you intend to invite must be provided.' }
  # End - RUBY VALIDATIONS: 
  
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations.   
  # Below - Associates Invites as a one to many relationship with Workplaces. (Workplaces has many Invites)  
  belongs_to :workplace, class_name: "Workplace"
  # Below - Associates Invities as a one to many relationship with Admins. (Admins has many invitations (recipient_id) ) 
  belongs_to :sender, class_name: "Admin"
  # Below - Associates invites as a one to many relationship with Admins. (Admins has many sent_invites (sender_id))  
  belongs_to :recipient, class_name: "Admin", optional: true
  # Below - Allows invites to have a department assigned to them optionally.
  #belongs_to :department, class_name: "WorkplaceDepartment", foreign_key: "workplace_department_id", optional: true
  # Below - Associates Invite as a has one city through workplace. (City can be associated with invite)  
  has_one :institute, through: :workplace 
# End - ASSOCIATIONS: Many/Belongs To/One Relations. 

# Begin - METHODS: Custom Methods and model calls.
 
# End - METHODS: Custom Methods and model calls.

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  # Below - Callback after an invite is created to generate a secure token with the invite. 
  before_create :generate_token
  # Below - Checks if the admin already has an account during invite to workplace.
  before_save :check_admin_existence

  def check_admin_existence
    recipient = Admin.find_by_email(self.email)
    if recipient
      self.recipient_id = recipient.id
    end
  end
  
  # Below - Token for invite into a workplace
  def generate_token
     self.token = Digest::SHA1.hexdigest([self.workplace_id, self.institute.id, Time.now, rand].join)
  end

# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.

    
  
  
end

class ComplaintReply < ApplicationRecord
# Main model for Admins interacting with complaints via the submit plan action.

# Begin - SCOPES: Scopes for records.

# End - SCOPES: Scopes for records.

# Begin - Gems and acts_as setups. 
 
# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.

# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.
  
# Begin - ASSOCIATIONS: All Associations of model Table to other tables.
  # Below - Associates a one to one relationship with complaints. (Complaint has one Complaint_plan) 
  belongs_to :complaint
  # Below - Associates a one to one relationship with Users (admin's slave user from admins table).  
  belongs_to :user, class_name: "Admin", foreign_key: "user_id"
# End - ASSOCIATIONS: All Associations of model Table to other tables.

# Begin - MODEL METHODS: Custom Model Methods.
 
# End - MODEL METHODS: Custom Model Methods.


# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  
# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  
end 
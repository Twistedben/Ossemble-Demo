class Contact < ApplicationRecord
# Main Model for Contacts for Admins

# Begin - SCOPES: Scopes for records.
  
# End - SCOPES: Scopes for records.

# Begin - Gems and acts_as setups. 


# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level, Uniqueness and Character Limitations.
  
  # Begin - CUSTOM VALIDATIONS: 
  
  # End - CUSTOM VALIDATIONS: 
  
  # Begin - RUBY VALIDATIONS: 
    # Below - Plain validation of name field and information field.
    validates :name, presence: { message: 'must be included to identify the type of contact information.' }
    validates :information, presence: { message: 'must be included in order to contact you.' }
  # End - RUBY VALIDATIONS: 
  
# End - VALIDATIONS: 

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations.   
  
  # Below - Associates Contact as a many to one relationship with Admins. (Admins has many contacts)  
  belongs_to :admin

# End - ASSOCIATIONS: 

# Begin - METHODS: Custom Methods and model calls.
  # Below -  Checks and returns 
  def is_email? 
     if self.information.include?("@") && self.information.include?(".")
       return true
     else
       return false
     end 
  end   
# End - METHODS: 

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  

# End - CUSTOM CALLBACKS: 




end 
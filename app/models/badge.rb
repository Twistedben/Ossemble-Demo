class Badge < ApplicationRecord
# Main model for Badges table. Associates with users and the reputation system.
  
# Begin - Gems and acts_as setups. 

# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level, Uniqueness and Character Limitations.

# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations.   
  # Below - Associates badges with users.
  belongs_to :user   
# End - ASSOCIATIONS: Many/Belongs To/One Relations. 

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  validates :user_id, presence: true
  validates :title, presence: true

# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.

  
end

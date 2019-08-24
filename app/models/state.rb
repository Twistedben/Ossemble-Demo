class State < ApplicationRecord
# Main Model for Following resources and :follows table. Links up with Acts_as_follower gem and the follows_controller.rb controller.
  
# Begin - SCOPES: Scopes for Posts.

# End - SCOPES: Scopes for Posts.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.
  # Below - Plain validation of a state's name.  
  validates :name, presence: { message: 'A state must have a name.' }
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.
  
# Begin - ASSOCIATIONS
  # Below - Associates BLANK as a one to BLANK relationship with BLANK. (BLANK has BLANK)  
  has_many :counties, class_name: "County", foreign_key: "state_id"
  # Below - Associates States as a has many to one relationship with cities. (city belongs_to states.)  
  has_many :cities, :through => :counties
# End - ASSOCIATIONS

# Begin - CUSTOM METHODS

# End - CUSTOM METHODS

end

class Report < ApplicationRecord
  
  
# Begin - SCOPES: Scopes for records.
  # Below - Orders created to the top of the list in descending order.
  default_scope { order(created_at: :desc)}
  
# End - SCOPES: Scopes for records.


# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level, Uniqueness and Character Limitations.
  
  # Begin - CUSTOM VALIDATIONS: 
  
  # End - CUSTOM VALIDATIONS: 
  
  # Begin - RUBY VALIDATIONS: 
  validates :name, presence: { message: 'A report must have a name associated with it.' }
  validates_presence_of :reported_id
  validates_presence_of :reporter_id
  validates_presence_of :offender_id
  # End - RUBY VALIDATIONS: 
  
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.

# Begin - ASSOCIATIONS:

# Below - Associates BLANK as a one to BLANK relationship with BLANK. (BLANK has BLANK)  
#belongs_to :user 
#belongs_to :comment

# Begin - METHODS: Custom Methods and model calls.
 
# End - METHODS: Custom Methods and model calls.

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  

# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.

end

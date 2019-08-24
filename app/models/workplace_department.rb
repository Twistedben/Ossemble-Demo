class WorkplaceDepartment < ApplicationRecord
# Main Model for workplace departments, created inside Workplace to assign members to and create a DB record for.


# Begin - SCOPES: Scopes for records.
  # Below - Orders created to the top of the list in descending order.
  #default_scope { order(created_at: :desc)}
  
# End - SCOPES: Scopes for records.

# Begin - Gems and acts_as setups. 
  # Below - PUBLICACTIVITY: Loads in Public Activity Gem for tracking of creation of records
  #include PublicActivity::Model
  # Below - Adds Tracking to this model for PubliCActivity
  #tracked
  # Below - FRIENDLYID: Adding FriendlyID to this model so BLANK is URL instead of ID. 
  #extend FriendlyId
  #friendly_id :slug_candidates, use: [:slugged, :finders]
    # Below -  Generates the slug based on BLANK
  #  def slug_candidates
  #   [
  #    :FIELD_NAME,
  #      [:FIELD_NAME, :FALLBACK_FIELD],
  #      [:FIELD_NAME, :FALLBACK_FIELD, :LAST_FALLBACK]
  #    ]
  #  end 
  # Below - Determines if there's a blank or new Record to assign a slug to.
  #def should_generate_new_friendly_id?
  #  new_record? || slug.blank?
  #end
  # Below - ACTS_AS_VOTABLE - Acts_as_votable gem to allow upvotes for this model.
  #  acts_as_votable
  # Below - PUNCHABLE: Allows Acts_as_punchable (trending) for BLANK from the punching_bag gem.
  #  acts_as_punchable
  # Below - ACTS AS FOLLOWER: Allows following.
    # Below - Allows BLANK to be followed
  #  acts_as_followable

# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level, Uniqueness and Character Limitations.
  
  # Begin - CUSTOM VALIDATIONS: 
  
  # End - CUSTOM VALIDATIONS: 
  
  # Begin - RUBY VALIDATIONS: 
    # Below - Validates character length of department description  
    validates_length_of :name, :minimum => 1, :maximum => 60,  
      :too_long => "The maximum characters for a name is 60 characters.",  
      :too_short => "A department must have a name.",
      allow_blank: false
    # Below - Validates character length of department description  
    validates_length_of :description, :minimum => 1, :maximum => 255,  
      :too_long => "The maximum character limit for a description is 255 characters.",  
      :too_short => "Too short of a description.",
      allow_blank: true
    # Below - Validates uniqueness of Department name with the workplace so a department isn't created twice.
    validates_uniqueness_of :name, scope: :workplace_id, message: "This department has already been created.", case_sensitive: false
  # End - RUBY VALIDATIONS: 
  
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations.   
  # Below - Associates Deparments as a one to many relationship with Workplace. (Workplace has many WorkplaceDepartments)  
  belongs_to :workplace
  # Below - Associates departments as a one to one with city through the workplace association.
  has_one :city, through: :workplace
  # Below - Associates Departments as a has many to one relationship with Admins. (Admins belong to departments [admin.department])  
  has_many :admins, class_name: "Admin", foreign_key: "workplace_department_id"
# End - ASSOCIATIONS: Many/Belongs To/One Relations. 

# Begin - METHODS: Custom Methods and model calls.
 
# End - METHODS: Custom Methods and model calls.

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  

# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.

  
  
  
end

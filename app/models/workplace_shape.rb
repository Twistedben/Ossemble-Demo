class WorkplaceShape < ApplicationRecord
# Main Model for Workplace Shapes for Workplaces, generating goejson
 

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

# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level, Uniqueness and Character Limitations.
  
  # Begin - CUSTOM VALIDATIONS: 
  
  # End - CUSTOM VALIDATIONS: 
  
  # Begin - RUBY VALIDATIONS: 
    # Below - Plain validation of geo   
    validates :geo, presence: { message: "Please click on the map to select the Channel's location" }
  # End - RUBY VALIDATIONS: 
  
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations.   
  
  # Below - Associates WorkplaceShape as a one to one relationship with Workplaces. (Workplaces has one shape)  
  belongs_to :workplace
  
# End - ASSOCIATIONS: Many/Belongs To/One Relations. 

# Begin - METHODS: Custom Methods and model calls.
 
# End - METHODS: Custom Methods and model calls.

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  

# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.

  
end

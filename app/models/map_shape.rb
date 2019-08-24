class MapShape < ApplicationRecord
# Main Model for Map Shapes created in Workplaces, nested under WorkplaceMapPosts. These records render the location of drawn shapes on leaflet maps, using Leaflet.draw.
  # This is the records for Map resources to store latitude, longitude, and the type of shape drawn.


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
    # Below - Validates presence of BLANK  
    validates_presence_of :geo, message: "A Map Post needs a location. Please draw a shape on the map."
  # End - RUBY VALIDATIONS: 
  
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations.   
  # Below - Associates Map Shape as a one to Many relationship with WorkplaceMapPosts. (Workplace Map Post has many map_shapes, as :shapes) 
  belongs_to :map_post, class_name: "WorkplaceMapPost", foreign_key: "workplace_map_post_id", optional: true
  # Below - Associates Map Shape as a one to Many relationship with WorkplaceMapPosts. (Workplace Map Post has many map_shapes, as :shapes) 
  belongs_to :project, class_name: "MapProject", foreign_key: "map_project_id", optional: true
# End - ASSOCIATIONS: Many/Belongs To/One Relations. 

# Begin - METHODS: Custom Methods and model calls.
 
# End - METHODS: Custom Methods and model calls.

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  

# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.

  

end

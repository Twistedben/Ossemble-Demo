class LibraryEntry < ApplicationRecord
# Main model for Library Entries inside an ADmin's LIbrary. 

# Begin - SCOPES: Scopes for records.
  # Below - Orders created to the top of the list in descending order.
  default_scope { order(created_at: :desc)}
   # Below - Scopes entries by workplace reports  
  scope :uploads, -> { where(:entriable_type => "LibraryUpload")}
   # Below - Scopes entries by ones that are shares.  
  scope :shared, -> { where(:shared => true)}
  # Below - Custom method for grouping workplace suggestions and reports together as maps
  def self.shared_posts 
    shared_posts = self.where(shared: true, entriable_type: "WorkplacePost") + self.where(shared: true, entriable_type: "WorkplaceMapPost")
  end 
  # Below - Scope to return just workplace map posts entries that aren't from a shared resource.
  def self.maps
    reports = self.where(shared: false, entriable_type: "WorkplaceMapPost")
  end 

  # Below - Scope to return just workplace reports entries that aren't from a shared resource.
  def self.posts
    posts = self.where(shared: false, entriable_type: "WorkplacePost")
  end 
  
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
  #    [:FIELD_NAME, :FALLBACK_FIELD],
  #    [:FIELD_NAME, :FALLBACK_FIELD, :LAST_FALLBACK]
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
    
    # Below - Validates uniqueness of BLANK  
    validates_uniqueness_of :entriable_id, scope: [:entriable_type, :admin_library_id], message: "You've already saved this to your library."
  # End - RUBY VALIDATIONS: 
  
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations.   
  # Below - Creates a polymorphic vitrual table for Workplace Posts, Suggestions, and Reports. (WorkplacePosts, Reports, Suggestions has_many library_entries, as => :entriable)
  belongs_to :entriable, :polymorphic => true
  # Below - Associates library entry with admin library (admin_library has_many :library_entries)
  belongs_to :library, class_name: "AdminLibrary", foreign_key: "admin_library_id"
  # Below - Associates library entry with another admin to be shared to as a receiver (admin has_many received_entries)
  belongs_to :receiver, class_name: "Admin", foreign_key: "admin_id", optional: true 
  # Below - Associates library entry with the admin sending a share  to a receiver (admin has_many sent_entries)
  #belongs_to :sender, class_name: "Admin", foreign_key: "admin_id", optional: true 
  # Below - Associates library entry with admin through using admin_library 
  has_one :admin, :through => :library
# End - ASSOCIATIONS: Many/Belongs To/One Relations. 

# Begin - METHODS: Custom Methods and model calls.
  # Below -  
  def sender 
     sender = Admin.find self.sender_id
     return sender
  end   
# End - METHODS: Custom Methods and model calls.

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  

# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.

  
  
  
end

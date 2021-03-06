class WorkplaceMapPost < ApplicationRecord
# Main Model for Map Pin creation 

# Begin - SCOPES: Scopes for records.
  # Below - Orders created to the top of the list in descending order.
  default_scope { order(created_at: :desc)}
  # Below - Scopes Map Posts by  "Suggestion" category
  scope :suggestions, -> { where(:map_post_category_id => 1)}
  # Below - Scopes Map Posts by  "Report" category
  scope :reports, -> { where(:map_post_category_id => 2)}
  # Below - Scopes Map Posts by  "Report" category
  scope :others, -> { where(:map_post_category_id => 3)}
  # Below - Returns only map posts that are markers
  def markers 
    self.shapes.where(category: "marker")
  end 
# End - SCOPES: Scopes for records.

# Begin - Gems and acts_as setups. 
 # Below - PUBLICACTIVITY: Loads in Public Activity Gem for tracking of creation of records
  include PublicActivity::Model
  # Below - Adds Tracking to this model for PubliCActivity
  tracked
  # Begin - FRIENDLYID
    # Below - FRIENDLYID: Adding FriendlyID to petitions so Title is URL instead of ID. 
    extend FriendlyId
    friendly_id :slug_candidates, use: [:slugged, :finders]
    # Below -  Generates the slug based on BLANK
    def slug_candidates
      [
        [:title],
        [:title, :address],
        [:title, :address, :id]
      ]
    end 
   # Below - Determines if there's a blank or new Record to assign a slug to.
    def should_generate_new_friendly_id?
      new_record? || slug.blank?
    end
  # End - FRIENDLYID
  # Below - ACTS_AS_VOTABLE - Acts_as_votable gem to allow upvotes for this model.
    acts_as_votable
  # Below - PUNCHABLE: Allows Acts_as_punchable (trending) for map posts from the punching_bag gem.
    acts_as_punchable
  # Below - ACTS AS FOLLOWER: Allows following.
    # Below - Allows map posts to be followed
    #acts_as_followable

# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level, Uniqueness and Character Limitations.
  
  # Begin - CUSTOM VALIDATIONS: 

  # End - CUSTOM VALIDATIONS: 
  
  # Begin - RUBY VALIDATIONS: 
    # Below - Validates the length of the address inputted. 
    validates_length_of :address, :minimum => 1, :maximum => 50, 
      :too_long => "We appreciate how descriptive you are, but the maximum characters for a address/location is 50. Please be more succinct.", 
      :too_short => "Please provide an address or descriptive location. EG: 'Near the Ball Park' or '123 Main Street'." 
    # Below - Validates the length of the title inputted. 
    validates_length_of :title, :maximum => 70, 
      :too_long => "The maximum characters for a title is 70. Please be more succinct.", 
      :allow_blank => true
    # Below - Validates the length of the description inputted. 
    validates_length_of :description, :minimum => 1, :maximum => 6000, 
      :too_long => "The maximum characters for a description is 6,000, which is about 900 words. Please be more succinct.", 
      :too_short => "Please include a description." 
   # Below - Plain validation of an admin being associated with a workplace map shape.  
   validates :admin_id, presence: { message: 'A Map Post must have a Workplace User associated with it.' }
   # Below - Plain validation of a workplace report needing a workplace to belong to.  
   validates :workplace_id, presence: { message: 'A Map Post must have a Workplace associated with it.' }
   # Below - Plain validation of a workplace report needing a workplace to belong to.  
   validates :map_post_category_id, presence: { message: 'Please select a category for your Map Post.' }
   # Below - Custom validation  validation of BLANK  
   validates_presence_of :shapes, message: "You must draw a shape on the map"
   validates_associated :shapes
  # End - RUBY VALIDATIONS: 
  
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations.   
  # Below - Associates Workplace Map Posts as a one to Many relationship with a admin. (admin has many workplace_posts)  
  belongs_to :admin
  # Below - Associates Workplace Map Posts as a one to Many relationship with a workplace. (workplace has many workplace_posts)  
  belongs_to :workplace
  # Below - Associates Workplace Map Posts as a one to many relationship with a Map Post Category. (MapPostCategory has many WorkplaceMapPosts, as map_posts)  
  belongs_to :map_post_category
  # Below - Associates Workplace Map Posts as a one to Many relationship with cities. (city has many workplace_posts through workplace)  
  has_one :institute, through: :workplace
  # Below - Associates Workplace Map Posts as a polymorphic association with comments.
  has_many :comments, as: :commentable, dependent: :destroy 
  # Below - Has many library entries through entriable polymorphic table. 
  has_many :library_entries, :as => :entriable, dependent: :destroy
  # Below - Associates WorkplaceMapPost as a has many to one relationship with Map Shapes. (Mapshape belongs_to WorkplaceMapPost, optional: true)  
  has_many :shapes, class_name: "MapShape", foreign_key: "workplace_map_post_id", dependent: :destroy
    # Below - Associates with notification and prevents orphaned notifications from causing errors.
  has_many :notifications, as: :notifiable, dependent: :destroy
  #  Below - Allows an image upload for WorkplaceMapPost, using active storage.  
  has_one_attached :image, dependent: :destroy
  #  Below - Allows a file upload for WorkplaceMapPost, using active storage.  
  has_one_attached :file, dependent: :destroy
  #  Below - Allows nested attributes for shapes (Map Shapes) table.  
  accepts_nested_attributes_for :shapes, allow_destroy: true, limit: 1 

# End - ASSOCIATIONS: Many/Belongs To/One Relations. 

# Begin - METHODS: Custom Methods and model calls.
  # Below - Returns the Workplace Map Post's associated map_post_category in name format.  
  def category 
   self.map_post_category.name
  end 
  
  # Below - Checks the tags input field to see if others were mentioned, and then used below in mentioned_admins method.
  def mentions
    @mentions ||= begin
                    regex = /@([\w]+\s[\w]+)/ 
                    tags.scan(regex).flatten
                  end
  end
  
  # Below - List of avaiable mentios
  def mentioned_admins
    mentioned_admins ||= self.workplace.admins.where(name: mentions)
  end
  
  # Below - Checks if the resource has been shared or not using tags inside creation.
  def is_shared? 
    if self.library_entries.where(shared: true).empty?
      return false
    else 
      return true
    end 
  end   

# End - METHODS: Custom Methods and model calls.

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  # Below - Allows Mentions inside Workplace Posts  to send a notification to shared admins.

  # Below - Callback that sends an email (TODO) and a notification and library entry to mentioned admins if any after creation.
  after_save :notify_and_share_admins
  
  # Below - Sends a notification to reciepient of tags in creation of resource, also adds a library entry to their archive.
  def notify_and_share_admins
    mentioned_admins.each do |mentioned|
      # Here put email 
      entry = self.library_entries.create(sender_id: self.admin.id, receiver_id: mentioned.id, admin_library_id: mentioned.library.id, shared: true)
      if entry.valid?
        Notification.create(recipient: mentioned, actor: self.admin, action: "shared", notifiable: self)
      end
    end
  end

# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.

end

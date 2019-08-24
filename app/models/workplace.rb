class Workplace < ApplicationRecord
# Main Model for Workplaces. Areas with public and private feeds for admins and workplace users.


# Begin - SCOPES: Scopes for records.
  # Below -  Custom Scope to return super admins of a workplace
  def super_admins
    self.admins.where(super_admin: true)
  end   
  # Below -  Returns a collection of demo geusts created by demo_admin_creation
  def return_guests
    self.admins.where(first_name: "Guest", institute_id: 1)
  end   

# End - SCOPES: Scopes for records.

# Begin - Gems and acts_as setups. 
  # Below - PUBLICACTIVITY: Loads in Public Activity Gem for tracking of creation of records
  #include PublicActivity::Model
  # Below - Adds Tracking to this model for PubliCActivity
  #tracked
  # Below - FRIENDLYID: Adding FriendlyID to this model so BLANK is URL instead of ID. 
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]
  # Below -  Generates the slug based on BLANK
    def slug_candidates
      [
        :name,
        [self.institute.slug, :name],
        [self.institute.slug, :name, :id]
      ]
    end 
  # Below - Determines if there's a blank or new Record to assign a slug to.
  def should_generate_new_friendly_id?
    new_record? || slug.blank?
  end
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
    # Below - Ensures a city is associated with a new workplace
    #validates :city_id,     presence: {message: "A Workplace must be associated with a City." }
    validates :institute_id, presence: {message: "A Channel must be associated with a Workplace." }
    # Below - Ensures a Workplace has a name is associated with a new workplace
    validates_length_of :name, :minimum => 1, :maximum => 255,
      :too_long =>  "A Workplace's name cannot exceed 255 characters",
      :too_short => "A Workplace must have a name and identifying title." 
    # Below - Ensures a city is associated with a new workplace
    validates_length_of :description, :minimum => 1, :maximum => 255,
      :too_long => "A Workplace's description cannot exceed 255 characters.",
      :too_short => "A Workplace must have a description."
    # Below - Validates presence of Workplace Name
    validates_presence_of :name, message: "Please enter a name for the Workplace."
     # Below - Validates presence of Workplace Description  
    validates_presence_of :description, message: "Please enter a description for the Workplace."
  # End - RUBY VALIDATIONS: 
  
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations.   
  # Below - Associates Workplace as a one to many relationship with Cities. (City has many Workplaces)  
  belongs_to :city, optional: true
  # Below - Associates Workplace as a one to many relationship with Institutes. (Institute has many Workplaces)  
  belongs_to :institute
  # Below - Associates BLANK as a has one to BLANK relationship with BLANK. (BLANK belongs to BLANK)  
  has_one :shape, class_name: "WorkplaceShape", foreign_key: "workplace_id", dependent: :destroy
  # Below - Associates Workplace as a has many to one relationship with Workplace Posts, allowing .posts to be called. (WorkplacePost belongs_to :workplace)  
  has_many :posts, class_name: "WorkplacePost", foreign_key: "workplace_id", dependent: :destroy
  # Below - Associates Workplace as a many to many relationship with Workplace_admins, using it as join table and naming is as members. (WorkplaceAdmin belongs_to :workplace)  
  has_many :members, class_name: "WorkplaceAdmin", foreign_key: "workplace_id", dependent: :destroy
  # Below - Associates Workplace as a many to many relationship with admins, through join table of WorkplaceAdmins. (Admin has_many :workplaces through: workplace_admins)  
  has_many :admins, through: :members
  # Below - Associates Workplaces as a has many to one relationship with Invite. (Invite belongs to Workpalce)  
  has_many :invites, class_name: "Invite", foreign_key: "workplace_id", dependent: :destroy#, inverse_of: :workplace
  # Below - Associates Workplaces as a has many to one relationship with Admin Chatrooms. (Admin Chatrooms belongs to Workplace)  
  has_many :admin_chatrooms, class_name: "AdminChatroom", foreign_key: "workplace_id", dependent: :destroy
  # Below - Associates Workplaces as a has many to one relationship with Workplace Map Shape. (WorkplaceMapShape belongs to Workplace)  
  has_many :map_posts, class_name: "WorkplaceMapPost", foreign_key: "workplace_id", dependent: :destroy
  # Below - Associates Workplaces as a has many to one relationship with Map Projects. (MapProjects belongs to Workplace)  
  has_many :projects, class_name: "MapProject", foreign_key: "workplace_id", dependent: :destroy
  # Below - Associates Workplace as a has many to one relationship with Workplace Departments. (WorkplaceDepartments belongs to Workplace)  
  has_many :workplace_departments, class_name: "WorkplaceDepartment", foreign_key: "workplace_id", inverse_of: :workplace, dependent: :destroy
  # Below - Allows nested attributes for workplace_departments and workplaces. The reject_if: rejects the creation if all of the attributes are blank, allows multiple creation on one page.
  accepts_nested_attributes_for :workplace_departments, reject_if: :all_blank,  allow_destroy: true
  accepts_nested_attributes_for :invites, reject_if: :all_blank,  allow_destroy: true
# End - ASSOCIATIONS: Many/Belongs To/One Relations. 

# Begin - METHODS: Custom Methods and model calls.
  
  # Below - Called after admin signs up in a create commit callback if the City has a City Workplace
  def join_workplace(admin)
    admin.workplaces.push(self) unless self.admins.include?(admin) # Pushes admin into city workplace unless they're already a member
  end   
  
  # Below - Sets a city workplace :activated boolean to true. This is most notably called in a after create callback from admin model when the first admin (temporary super_admin) of a city is created. 
    # Also creates a empty department for the workplace so that there are initial form fields on after_signup page
  def activate_workplace
    if self.activated == false      # Checks first to ensure workplace isn't already activated, then activates workplace.
      self.update(activated: true)  # Sets workplace activation to true. For now, there isn't much use to this but will be in the future.
    end
  end
  
  # Below - Checks if the workplace has a map shape associated with it.
  def has_shape?
    if self.shape.nil?      
      return false
    else 
      return true
    end
  end  
  
  # Below - Creates the first post (Workpalce Post) for a City Workplace after an super admin signs up for first time, and workplace posts are empty.
  def create_welcome_post(admin)
    if self.posts.empty?
      self.posts.create(title: "Welcome to #{self.name}!", 
        description: "<p><b>Welcome to Ossemble and thank you for joining.</b></p> <p>You, and anyone who joins this Channel, can collaborate using the Channel Map by clicking the 'Post' button above. Posts like this can also be created there, adding files and images for sharing. </p><p> Help others to join you and the workplace by opening the side panel to the left of your screen and clicking 'Invite Members'. Also in this panel, you can view the Channel feed, have an overview of the Channel Map, and the Channel Directory (where everyone can be found). </p><p> Thanks again, and feel free to <a class='title_link' href='/contact_us'>contact us</a> with any questions.</p>",
        admin_id: admin.id,
        tags: "",
        post_category_id: 2)
    end 
  end   
# End - METHODS: Custom Methods and model calls.

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  
  # Below - When a new workplace is created, a chatroom is created with it called general. 
    # This will be called after a new city is created as a default City Workplace is created when a new city is, which will trigger this callback and ensure there's a chatroom in place.
  #after_create_commit :new_default_chatroom
  
  # Below -  Called after a Workplace is created, generating a default chatroom for the workplace
 # def new_default_chatroom
  #  default_chatroom = self.admin_chatrooms.create(name: "General", description: "Default general Workplace chatroom for broad discussions.")
  #  puts "Default Admin Chatroom created for new Workplace: #{default_chatroom.inspect}"
  #end   

# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.

  
  
  
end

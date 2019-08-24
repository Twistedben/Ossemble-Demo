class LibraryUpload < ApplicationRecord
  # Main model for uploads from admins inside their own libraries, files, documents, images, etc.

# Begin - SCOPES: Scopes for records.
  # Below - Orders created to the top of the list in descending order.
  default_scope { order(created_at: :desc)}
  
# End - SCOPES: Scopes for records.

# Begin - Gems and acts_as setups. 
  # Below - PUBLICACTIVITY: Loads in Public Activity Gem for tracking of creation of records
  #include PublicActivity::Model
  # Below - Adds Tracking to this model for PubliCActivity
  #tracked
  # Below - FRIENDLYID: Adding FriendlyID to this model so title is URL instead of ID. 
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]
    # Below -  Generates the slug based on title
    def slug_candidates
      [
        :title,
        [:title, self.admin.last_name],
        [:title, self.admin.last_name, :id]
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
    # Below - Plain validation of title 
    validates :title, presence: { message: 'A title must be added to your upload.' }
    # Below - Plain validation of title 
    validates :admin_id, presence: { message: 'A user must be associated with an upload.' }
    # Below - Plain validation of title 
    validates :description, presence: { message: 'A description may accompany an upload (optional).' }, :allow_blank => true
    
  # End - RUBY VALIDATIONS: 
  
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations.   
  # Below - Associates Library Uploads with admins in a one to many relationship (admin has_many library_uploads) 
  belongs_to :admin
  # Below - Associates Library Uploads with admin_libraries in a one to many relationship so libraries hold uploads (admin_library has_many library_uploads)
  has_one :library, through: :admin
  # Below - Associates Uploads as a has one to many relationship with cities through use of city_id in admin owner. 
  has_one :institute, through: :admin
  # Below - Associates Library Uploads as a polymorphic association with comments.
  has_many :comments, as: :commentable, dependent: :destroy 
  # Below - Has many library entries through entriable polymorphic table. Allows for library entries to be added to uploads so they can be shared.
  has_many :library_entries, :as => :entriable, dependent: :destroy
  # Below - Allows LIbrary Uploads to have attached images
  has_one_attached :image, dependent: :destroy
  # Below - Allows Library uploads to have attached files.
  has_one_attached :file, dependent: :destroy
# End - ASSOCIATIONS: Many/Belongs To/One Relations. 

# Begin - METHODS: Custom Methods and model calls.
 
# End - METHODS: Custom Methods and model calls.

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  
  # Below - Allows Mentions inside Library Uploads to send a notification to shared admins.
  def mentions
    @mentions ||= begin
                    regex = /@([\w]+\s[\w]+)/ 
                    tags.scan(regex).flatten
                  end
  end
  
  def mentioned_admins
    mentioned_admins ||= self.institute.admins.where(name: mentions)
  end
  
  # Below - Checks if the resource has been shared or not using tags inside creation.
  def is_shared? 
    if self.library_entries.where(shared: true).empty?
      return false
    else 
      return true
    end 
  end   

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

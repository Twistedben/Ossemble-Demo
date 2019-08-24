class WorkplacePost < ApplicationRecord
# Main Model for Resource creation in Workplaces, posts like in forums. 

# Begin - SCOPES: Scopes for records.
  # Below - Orders created to the top of the list in descending order.
  default_scope { order(created_at: :desc)}
  
# End - SCOPES: Scopes for records.

# Begin - Gems and acts_as setups. 
  # Below - PUBLICACTIVITY: Loads in Public Activity Gem for tracking of creation of records
  include PublicActivity::Model
  # Below - Adds Tracking to this model for PubliCActivity
  tracked
  # Below - FRIENDLYID: Adding FriendlyID to this model so BLANK is URL instead of ID. 
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]
    # Below -  Generates the slug based on BLANK
    def slug_candidates
      [
        :title,
        [:title, :id]
      ]
    end 
  # Below - Determines if there's a blank or new Record to assign a slug to.
  def should_generate_new_friendly_id?
    new_record? || slug.blank?
  end
  # Below - ACTS_AS_VOTABLE - Acts_as_votable gem to allow upvotes for this model.
  acts_as_votable
  # Below - PUNCHABLE: Allows Acts_as_punchable (trending) for BLANK from the punching_bag gem.
  acts_as_punchable
  # Below - ACTS AS FOLLOWER: Allows following.
  # Below - Allows BLANK to be followed
  #acts_as_followable

# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level, Uniqueness and Character Limitations.
  
  # Begin - CUSTOM VALIDATIONS: 
  
  # End - CUSTOM VALIDATIONS: 
  
  # Begin - RUBY VALIDATIONS: 
      # Below - Validates length of title.
    validates_length_of :title,  :minimum => 1, :maximum => 70, 
      :too_long => "We appreciate how descriptive you are, but a title's maximum character length is 70. Please be more succinct.", 
      :too_short => "A Post must have a title.", 
      :allow_blank => false
    # Below - Validates length of post's description.
    validates_length_of :description,  :minimum => 1, :maximum => 6000, 
     :too_long => "We appreciate how descriptive you are, but a Post's maximum character length is 6,000 (about 900 words). Please be more succinct.", 
      :too_short => "We strive for posts that clearly describe your point and intention so everyone can benefit. The minimum length is 50 characters (about 10 words).", 
     :allow_blank => false
     # Below - Plain validation of an admin being associated with a workplace post.  
     validates :admin_id, presence: { message: 'A Workplace Post must have a Workplace User associated with it.' }
     # Below - Plain validation of a workplace post needing a workplace to belong to.  
     validates :workplace_id, presence: { message: 'A Workplace Post must have a Workplace associated with it.' }
     # Below - Plain validation of a workplace post category.  
     validates :post_category_id, presence: { message: 'A Workplace Post must have a Category associated with it.' }
  # End - RUBY VALIDATIONS: 
  
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations.   
  
  # Below - Associates WorkplacePosts as a one to Many relationship with admins. (admin has many workplace_posts)  
  belongs_to :admin
  # Below - Associates WorkplacePosts as a one to Many relationship with workplaces. (workplace has many workplace_posts)  
  belongs_to :workplace
  # Below - Associates WorkplacePosts as a one to Many relationship with PostCategory (post_category has_many workplace_posts)
  belongs_to :post_category
  # Below - Associates WorkplacePosts as a one to Many relationship with cities. (city has many workplace_posts through workplace)  
  has_one :institute, through: :workplace
  # Below - Associates WorkplacePosts as a polymorphic association with comments.
  has_many :comments, as: :commentable, dependent: :destroy 
  # Below - Has many library entries through entriable polymorphic table. 
  has_many :library_entries, :as => :entriable, dependent: :destroy
  # Below - Associates with notification and prevents orphaned notifications from causing errors.
  has_many :notifications, as: :notifiable, dependent: :destroy
  #  Below - Allows an image upload for WorkplacePosts, using active storage.  
  has_one_attached :image, dependent: :destroy
  #  Below - Allows a file upload for WorkplacePosts, using active storage.  
  has_one_attached :file, dependent: :destroy
  
  
# End - ASSOCIATIONS: Many/Belongs To/One Relations. 

# Begin - METHODS: Custom Methods and model calls.

  # Below - Returns the post's belonging category
  def category
    self.post_category.name
  end
  
# End - METHODS: Custom Methods and model calls.

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.

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
  
  # Below - Callback that sends an email (TODO) and a notification and library entry to mentioned admins if any after creation.
  after_save :notify_and_share_admins
  
  # Below - Sends a notification to reciepient of tags in creation of resource, also adds a library entry to their archive.
  def notify_and_share_admins
    mentioned_admins.each do |mentioned|
      # Here, Send an email
      entry = self.library_entries.create(sender_id: self.admin.id, receiver_id: mentioned.id, admin_library_id: mentioned.library.id, shared: true)
      if entry.valid?
        Notification.create(recipient: mentioned, actor: self.admin, action: "shared", notifiable: self)
      end
    end
  end

# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.

   
  
  
end

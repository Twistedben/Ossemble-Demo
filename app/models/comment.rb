class Comment < ApplicationRecord
# Main Comment Model.

# Begin - Scopes for Comments. 
  # Below - Orders comments by recently created at the top in descending order. 
  default_scope -> { order(created_at: :desc)}

# Begin - Gems and acts_as setups. 
  # Below - PUBLICACTIVITY: Loads in Public Activity Gem for tracking of users' comments
  include PublicActivity::Model
  # Below - Adds Tracking to this model for PubliCActivity
  tracked
  # Below - ACTS_AS_VOTABLE - Acts_as_votable gem to allow upvotes on City Reviews.
  acts_as_votable

# End - Gems and acts_as setups. 
  
# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level, Uniqueness and Character Limitations.
  # Below - Validates the length of the address inputted. 
  validates_length_of :description, :minimum => 1, :maximum => 4000, :too_long => "We appreciate how descriptive you are, but a comment should be succinct and to the point; less than 4,000 characters (about 600 words).", :too_short => "Ensure your comment productively adds to the discussion!" 
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.
  
# Begin - ASSOCIATIONS: Many/Belongs To/One Relations for Comments.   
  # Below - Polymorphic association with Commentable so that comments belong to the interface table Commentable.
  belongs_to :commentable, polymorphic: true
  # Below - Comments belong to users. Users have many comments and are dependent on destruction. (Users has_many :comments)
  belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
  # Below - Comments belong to Admins. Admins have many comments and are dependent on destruction. (Admins has_many :comments)
  belongs_to :admin, class_name: "Admin", foreign_key: "admin_id", optional: true
  # Below - Polymorphic association with Comments so that the comments can have comments in the form of replies.
  has_many :comments, :as => :commentable
  # Below - COmments has_many replies, allowing a comment to have comments, with the foreign key being the parent id.
  has_many :replies, class_name: "Comment", foreign_key: :commentable_id, dependent: :destroy
  # Below - Associates comments as a one to reports relationship with offender id. 
  has_many :reports, class_name: "Report", foreign_key: "offender_id"
  # Below - Associates with notification and prevents orphaned notifications from causing errors.
  has_many :notifications, as: :notifiable, dependent: :destroy

  
# End - ASSOCIATIONS: Many/Belongs To/One Relations for Comments.    

# Begin - METHODS: Methods for comments
  # helper method to check if a comment has replies/children.
  def has_replies?
    self.replies.count > 0
  end
  
  # Below - counts replies if comment has them and adds pluralization or singularization, returning 0 if none.
  def count_replies 
    if self.has_replies?
      return self.replies.count
    else 
      return 0
    end 
  end
  # Below -  Finds the comments parent resource, page subject
  def parent
    page_parent = self.subject # Assigns the parent type so a punch can be added.
    page_id     = self.parent_id   # Finds the parent type's ID so a punch can be added.
    page        = page_parent.constantize.find(page_id) # Finds the page to add the punch to.
  end   
  
  # Below - Adds up all comments associated within a page.
    # Find "count_comments method in Application.rb. 

  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  scope :find_comments_by_user, lambda { |user|
    where(user_id: user.id).order('created_at DESC')
  }

  # Helper class method to look up all comments for
  # commentable class name and commentable id.
  scope :find_comments_for_commentable, lambda { |type, id|
    where(commentable_type: type.to_s,
          commentable_id: id).order('created_at DESC')
  }

# End - METHODS: Methods for comments
  
# Begin - CALLBACKS


# End - CALLBACKS  
  
end

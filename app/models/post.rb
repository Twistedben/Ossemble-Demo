class Post < ApplicationRecord
# Main model for Posts feature inside of Ossembly. Post is beneath Subtopic, beneath Topic, beneath Ossembly, Posts < Posts, Posts < Posts, Posts < Ossembly
# Begin - SCOPES: Scopes for Posts.
  # Below - Orders Posts that have been recently updated/created to the top of the list.
    default_scope { order(created_at: :desc)}
# End - SCOPES: Scopes for Posts.

# Begin - Gems and acts_as setups. 
  # Below - PUBLICACTIVITY: Loads in Public Activity Gem for tracking of users' comments
  include PublicActivity::Model
  # Below - Adds Tracking to this model for PubliCActivity
  tracked

  # Below - FRIENDLYID: Adding FriendlyID to Posts URL so Subtopic Name is URL (/posts/look-at-me-dog!) instead of ID. 
    extend FriendlyId
    friendly_id :title, use: [:slugged, :finders]
    # Below - Determines if there's a blank or new Record to assign a slug to.
    def should_generate_new_friendly_id?
      new_record? || slug.blank?
    end
  # Below - PUNCHABLE: Allows Acts_as_punchable for Posts from the punching_bag gem.
    # Sets up Posts for punching bag hits.
    acts_as_punchable
  # Below - VOTABLE: Allows Acts_as_Votable for Posts.
    # Sets up Posts for users to vote on. Cacheable_strategy removes the Updated_at time from being updated when a post is voted on.
    acts_as_votable
  # Below - ACTS AS FOLLOWER: Allows following.
    # Below - Allows Posts to be followed
    #acts_as_followable
# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Validations for Posts Table.
  validates :subtopic_id, presence: { message: "Please select the relevant subtopic that you want your post to appear in." }
  # Below - Validates length of title.
  validates_length_of :title,  :minimum => 1, :maximum => 70, 
    :too_long => "We appreciate how descriptive you are, but a title's maximum character length is 70. Please be more succinct.", 
    :too_short => "A Conversation must have a title.", 
    :allow_blank => false
  # Below - Validates length of post's description.
  validates_length_of :description,  :minimum => 25, :maximum => 6000, 
    :too_long => "We appreciate how descriptive you are, but a Conversation's maximum character length is 6,000 (about 900 words). Please be more succinct.", 
    :too_short => "We strive for posts that clearly describe your point and intention so everyone can benefit. The minimum length for a Conversation is 25 characters (about 5 words).", 
    :allow_blank => false
# End - VALIDATIONS: Validations for Posts Table.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations for Posts table.   
  # Below - Associates Posts with Subtopic using a one to many relation: (Subtopics has many posts)
  belongs_to :subtopic 
  # Below - Associates Posts with User using a one to many relation: (User has many posts)
  belongs_to :user 
  # Below - Associates BLANK as a one to BLANK relationship with BLANK. (BLANK has BLANK)  
  belongs_to :city
  # Below - Associates Posts with Comments through polymorphic commentable table. 
  has_many :comments, :as => :commentable, dependent: :destroy
  # Below - Associates Post with Topic so @post.topic can be called.
  has_one :topic, :through => :subtopic
  # Below - Attaches Active Storage to subtopics as a has many relationship. If a post is deleted, so are its attached images.
  has_one_attached :image, dependent: :destroy

# End - ASSOCIATIONS: Many/Belongs To/One Relations for Posts table.   

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for Topic Model.
 

# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for Topic Model.

end

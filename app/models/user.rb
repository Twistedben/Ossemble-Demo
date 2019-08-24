class User < ApplicationRecord

# Ossemble's main User Model and users' associations and Devise connections and OmniAuth configuration and FriendlyID and CarrierWave.
  
# Begin - SCOPES: Scopes for Users.
  #  Below - Scope for eager loading Active Storage images
    # Note that implicit association has a plural form in this case
  scope :with_eager_loaded_images, -> { eager_load(avatars_attachments: :blob) }
  # Below - Scopes users by verified ones
  scope :verified, -> { where(:verified => true)}
  # Below - Scopes users by non-verified ones
  scope :unverified, -> { where(:verified => false)}
  # Below - Scopes Users by non-guests
  scope :citizens, -> { where(:guest => false)}
  # Below - Scopes Users by non-guests
  scope :facebookers, -> { where(:provider => "facebook")}
  # Below -  Returns badges that aren't of the main four default ones.
  def unique_badges  
    self.badges.where.not(title: "Ownership").where.not(title: "Persistence").where.not(title: "Gratitude").where.not(title: "Communication")
  end   
# End - SCOPES: Scopes for Users.

# Begin - Gem and acts_as setup.
  # Below - PUBLICACTIVITY: Loads in Public Activity Gem for tracking of users' comments
  include PublicActivity::Model
  # Below - Adds Tracking to this model for PubliCActivity
  tracked
  # Begin - FRIENDLYID: Setting up URL for user to be Name instead of ID.
    extend FriendlyId
    friendly_id :slug_candidates, use: [:slugged, :finders]
    # Below -  Generates the slug based on user's name field and id at the end
    def slug_candidates
      unless self.first_name.blank? || self.last_name.blank?
        if self.name.blank? && first_name != "Facebook"
          self.set_full_name
          self.slug_candidates
        else
          [
            :name,
            [:city_id, :name],
            [:city_id, :name, :id]
          ]
        end
      end
    end 
    # Below - Determines if there's a blank or new Record to assign a slug to.
    def should_generate_new_friendly_id?
      new_record? || slug.blank?
    end
  # End - FRIENDLYID: Setting up URL for user to be Name instead of ID
  # Below - ACTSASTAGGABLE: Allows users to own tags 
    acts_as_tagger
  # Below - RATYRATE: Allowing Users to use RatyRate options inside of Reviews to affect Departments.
    ratyrate_rater
  # Below - VOTABLE: Allows Acts_as_Votable for Users.
    acts_as_voter
  # Below - ACTS AS FOLLOWER: Allows following.
    # Below - Allows users to be followed
    #acts_as_followable
    # Below - Allows Users to follow resources
    #acts_as_follower
  # Begin - MAILBOXER : Messages
    # Below - Allows Users to be messaged and message
    acts_as_messageable
    # Below - Sets up mailboxer_email method for acts as messeagable and Mailboxer gem
    def mailboxer_email(object)
      nil
    end
  # End - MAILBOXER : Messages
# End - Gem and acts_as setup.

# Begin - DEVISE: Devise Modules. We have not used = :timeoutable  :lockable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, 
         :validatable, :confirmable, :lockable,
         :omniauthable, omniauth_providers: [:facebook]
# End - DEVISE: Devise Modules. We have not used = :timeoutable, :lockable

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations
  # Below - Custom Validation for gender selection  
  def gender_selection
    if self.gender.blank?
      errors.add(:gender, "must be chosen.")
      return true
    end
  end   
  # Below - Custom Validation for First name  
  def validate_first_name
    if self.first_name.blank?
      errors.add(:first_name, "must be entered.")
      return true
    end
  end   
  # Below - Custom Validation for last name  
  def validate_last_name
    if self.last_name.blank?
      errors.add(:last_name, "must be entered.")
      return true
    end
  end   
  

  #PAssword and email is validated by Devise
  validate :validate_first_name
  validate :validate_last_name
  validates :dob, presence: { message: "Date of Birth must be selected" }
  validates :state, presence: true
  validates :street, presence: true, :allow_blank => true
  validates :zip_code, presence: true, :allow_blank => true
  validate :gender_selection
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations
  
# Begin - ASSOCIATIONS: All Associations of Users Table to other tables (Many to One - City & Many to One - Reviews).
  
  # Below - Associates Users into a One to Many relationship with Cities (Cities Has_many Users).
  belongs_to :city
  # Below - Associates users with admins as to OPTIONAL one to one relationship. (Admin has one user)  
  has_one :admin, -> {where(admin: true)} 
   accepts_nested_attributes_for :admin

  # Below - Associates Users as a has one to one relationship with Location. (Location belongs to user)  
  has_one :location, class_name: "Location", foreign_key: "user_id", dependent: :destroy
  # Below - Associates Users with Counties one to many through Cities. (Counties has many users through cities)
  has_one :county, :through => :city
  # Below - Associates City Review with Users, by allowsing Users to create City Reviews (CityReviews belongs_to user)
  has_one :city_review, class_name: "CityReview", foreign_key: "user_id", dependent: :destroy
  # Below - Associates Users to Department Reviews as a Has Many to Belongs to association (DepartmentReview Belongs_to Users). If user is destroyed, so are Reviews added by that user. Needs validation so each one can be reviewed only once.
  has_many :department_reviews, class_name: "DepartmentReview", foreign_key: "user_id", dependent: :destroy
  # Below - Complaints are created by users. Sets up a One to Many association with Users to Complaints (Complaint belongs_to Users). If user is destroyed, so are complaoints added by that user.
  has_many :complaints, class_name: "Complaint", foreign_key: "user_id", dependent: :destroy
  # Below - Associaties the Complaints table column "verified_by_user_id" with users. 
  has_many :verified_by, class_name: "Complaint", foreign_key: "verified_by_user_id"
  # Below - Associates Comments with Users, by allowing Users to create comments and have many. (Comments belongs_to user). If user is destroyed so are comments,
  has_many :comments, dependent: :destroy
  # Below - Associates Subtopics with Users, by allowing Users to create and have many. (Subtopics will not have the other end of the association)
  has_many :subtopics, dependent: :destroy
  # Below - Associates Users with posts, by allowing Users to create and have many. (Posts belongs_to user)
  has_many :posts, class_name: "Post", foreign_key: "user_id", dependent: :destroy
  # Below - Associates users with activities so @User.activities can be called.
  has_many :activities, class_name: "PublicActivity::Activity", foreign_key: "owner_id", dependent: :destroy
  # Below - Associates Users as a has many to one relationship with Petitions. (petitions belongs to users)  
  has_many :petitions, class_name: "Petition", foreign_key: "user_id", dependent: :destroy
  # Below - Allows calling for User.endorsements to get all upvotes not affiliated with petitions.
  has_many :endorsements, -> {where.not(votable_type: "Petition")}, class_name: "ActsAsVotable::Vote", foreign_key: "voter_id", dependent: :destroy
  # Below - Allows for calling of User.signatures to get all upvotes for Petitions.
  has_many :signatures, -> {where(votable_type: "Petition")}, class_name: "ActsAsVotable::Vote", foreign_key: "voter_id", dependent: :destroy
  # Below - Associates BLANK as a has many to BLANK relationship with BLANK. (BLANK has BLANK)  
  has_many :notifications, class_name: "Notification", foreign_key: "recipient_id"
  # Below - Associates reports as a has many to user relationship with reporter id.  
  has_many :reports, class_name: "Report", foreign_key: "reporter_id"
  # Below - Associates user as a has many to reports relationship with reported id.  
  has_many :reported, class_name: "Report", foreign_key: "reported_id"
  # Below - Associates user as a has many to chatrooms.  
  has_many :chatroom_user
  has_many :chatrooms, through: :chatroom_users
  has_many :messages
  # Begin - Badge Associations 
    # Below - Specific association for @user.ownership calls for the ownership badge.
    has_one :ownership, -> {where(title: "Ownership")}, class_name: "Badge", foreign_key: "user_id"
    # Below - Specific association for @user.communication calls for the communications badge.
    has_one :communication, -> {where(title: "Communication")}, class_name: "Badge", foreign_key: "user_id"
    # Below - Specific association for @user.persistence calls for the persistence badge.
    has_one :persistence, -> {where(title: "Persistence")}, class_name: "Badge", foreign_key: "user_id"
    # Below - Specific association for @user.gratitude calls for the gratitude badge.
    has_one :gratitude, -> {where(title: "Gratitude")}, class_name: "Badge", foreign_key: "user_id"
    # Below - Associates the rest of the badges to users that are unique badges, like "Friend of The City", etc.
    has_many :badges 
  # End - Badge Associations 
  # Below - For active storage image uploads.
  has_one_attached :avatar, dependent: :destroy
# End - ASSOCIATIONS: All Associations of Users Table to other tables.
  
# Begin - OMNIAUTH-FACEBOOK: Two Methods to work with OmniAuth Facebook.
    # Below - Sets up Session and Omniauth Facebook User Signup and Login.
=begin 
    def self.new_with_session(params, session)
      super.tap do |user|
        if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
          user.email = data["email"] if user.email.blank?
        end
      end
    end
    # Below - Grabs Omniauth Facebook Hash for Facebook User Signup and Login 
    def self.from_omniauth(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.provider       = auth.provider
        user.uid            = auth.uid
        user.email          = auth.info.email
        user.password       = Devise.friendly_token[0,20] 
        user.name           = auth.info.name
        user.image          = auth.info.image
        user.first_name     = auth.first_name
        user.last_name      = auth.last_name
        user.skip_confirmation!
        user.save(validate: false)
      end
    end
=end
# End - OMNIAUTH-FACEBOOK: Two Methods to work with OmniAuth Facebook.

# Begin - METHODS: Custom Methods and model calls.
  # Below -  Returns a collection of signed petitions.
  def signed_petitions
    self.votes.where(votable_type: "Petitions")
  end   
   # Below - Checks if the user is a facebook user.
  def is_facebook_user?
    if self.provider == "facebook"
      return true
    elsif self.provider.nil?
      return false
    else 
      return false 
    end 
  end   
  # Below - Returns the number of content being following
  def following_content_count
    content_count = self.following_by_type_count("Petition") + self.following_by_type_count("Complaint") + self.following_by_type_count("Post")
  end   
  # Below -  Returns the content that the user is following
  def following_content
    content = self.following_by_type("Petition") + self.following_by_type("Complaint") + self.following_by_type("Post")
  end   
  # Below - Checks if user is following anything at all  
  def not_following? 
    return true if self.followings.empty?
  end   
  # Below -  Called by Badges_helper and inside User Show Page > _reputation.html.erb Partial. Displays the badge's threshold for its next level.
  def badge_ding_threshold(badge)
    case badge
    when "ownership"
      return "#{(self.ownership.level+1) * 250}"
    when "persistence"
      return "#{(self.persistence.level+1) * 75}"
    when "communication"
      return "#{(self.communication.level+1) * 100}"
    when "gratitude"
      return "#{(self.gratitude.level+1) * 100}"
    else 
      # Renders a failsafe
    end
  end   
  # Below -  Returns the unique badges 
  def awarded_unique_badges 
    self.unique_badges.pluck(:title)
  end   
  # Below - Checks if user has specific unique badge  
  def has_badge?(title)
    self.awarded_unique_badges.include?(title)
  end
  # Below - Counts number of unique badges a user has
  def count_unique_badges
    self.unique_badges.count
  end
  # Below -  Checks if the user is unverified. User as a simple method and also on the verify_user controller callback after user update.
  def unverified_user?
    return true if self.verified == false
  end   
  # Below -  Verifies the user if they enter their address and zip after updating their profile. Also awards them the pioneer badge if they don't have one and their the first 500 citizens of the city.
  def verify_user
    if self.verified == false
      if self.zip_code != nil || self.street != nil
        if self.location.street? && self.location.zip_code? 
          self.update_columns(verified: true, street: self.location.street, street2: self.location.street2, zip_code: self.location.zip_code)
          # Below - Awards pioneer badge to first 500 verified users.
          self.award_unique_badge("Pioneer") if self.city.users.count <= 500 && !self.has_badge?("Pioneer")
        end 
      end 
    end
  end   
  # Below -  Is called to determine if user filled out at least half their public profile 
  def filled_out_public? 
    if (self.neighborhood != "Not Specified" && self.resident_date?) || (self.title != "Resident" && self.bio?)
      return true
    else 
      return false
    end 
  end   
# Below -  Awards a unique (bonus) badge to a user with the title passed in and the user being awarded.
  def award_unique_badge(title) 
    case title 
    when "Pioneer"
      self.badges.create(title: "Pioneer", description: "One of the verified, founding members of a city.")
    when "Ally"
      self.badges.create(title: "Ally", description: "Has made some friends.")
    when "Friend of the City"
      self.badges.create(title: "Friend of the City", description: "Can fully contribute to other cities.")
    when "Moderator"
      self.badges.create(title: "Moderator", description: "Is a moderator of a city.")
    else
      # Fail safe
    end 
  end   
  
  # Below - Method for checking if the user is a resident of a passed in city. Used maily for checking if reviews will be counted toward score
  def is_resident_of?(city)
    if self.city == city
      return true # User is a resident of passsed in city.
    else   # User is not a resident of given city.
      return false
    end
  end   

# End - METHODS: Custom Methods and model calls.

# Begin - CUSTOM CALLBACKS: Before_save & Callbacks for User Model.
  # Below - Calls "set_full_name" method before saving to DB. Subscribes to mailerlite when a new user is created, and assigns the essential 4 default badges.
  after_create_commit :set_full_name, :new_badges
  # Below - IF the user's firt or last name has changed, then uppdates the user's :name field. 
  after_commit :update_full_name, on: :update 
  
    # Below - Creates new badges row when a user is created but not a guest.
    def new_badges
      unless self.guest?
        Badge.create(title: "Ownership", description: '', score: 0, user_id: self.id) unless self.ownership
        Badge.create(title: "Communication", description: '', score: 0, user_id: self.id) unless self.communication
        Badge.create(title: "Persistence", description: '', score: 0, user_id: self.id) unless self.persistence
        Badge.create(title: "Gratitude", description: '', score: 0, user_id: self.id) unless self.gratitude
      end
    end  
   
  # Below - Combines newly created user's first name and last name into the ":name" attribute. Allows name to be commited when user is coming from facebook.
    def set_full_name
      if self.is_facebook_user? && self.first_name.blank? # On create, the :name field is passed, but mot first name and last.
        self.first_name = "Facebook"
        self.last_name = "User"
      else  # User is not a facebook user, so name is treated differently. 
        if self.name.blank?
          self.name = "#{self.first_name} #{self.last_name}".strip
        else # This exists for Admin slave user creation.
          return false
        end
      end # End - facebook user check.
    end
  # Below - Runs when someone updates their name to generate the new :name attribute field.
    def update_full_name
      # Below - Checks if the name changed or not and is a not a newly created facebook user
      if self.name != "#{self.first_name} #{self.last_name}".strip && self.first_name != "Facebook"
        # Below - If the name changed, update the change.
        self.name = "#{self.first_name} #{self.last_name}".strip
      end 
    end

# End - CUSTOM CALLBACKS: Before_save & Callbacks for User Model.

end # End of User Model
class Concern < ApplicationRecord

# Begin - SCOPES: Scopes for concern.
  # Below - Orders Concerns that have been recently created to the top of the list in descending order.
  default_scope { order(created_at: :desc)}
  scope :reports, -> { where(category: "Report")}
  scope :suggestions, -> { where(category: "Suggestion")}
# End - SCOPES:

# Begin - GEMS/ACTS_AS SETUP:
  
# Begin -  Gems and Asct_as Setup
  # Below - PUBLICACTIVITY: Loads in Public Activity Gem for tracking of users' comments
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
          [:title, :address, self.city.name]
        ]
      end 
  
   # Below - Determines if there's a blank or new Record to assign a slug to.
    def should_generate_new_friendly_id?
      new_record? || slug.blank?
    end
  # Below - ACTS_AS_VOTABLE - Acts_as_votable gem to allow upvotes on concerns.
    acts_as_votable
  # Below - PUNCHABLE: Allows Acts_as_punchable (trending) for concerns from the punching_bag gem.
    acts_as_punchable
  # Below - ACTS AS FOLLOWER: Allows following.
    # Below - Allows concerns to be followed
    #acts_as_followable

# End - GEMS/ACTS_AS SETUP:

# Begin - VALIDATIONS:

  validates_uniqueness_of :latitude, scope: :longitude, presence: {
            message: "Your concern's location has already been recorded as an active concern. If you believe it is not a duplicate of an already filed concern, then reposition the map marker as close to its location as possible." }
  # Below - Ensures Longitude  is unique based on the latitude being different and ensures a pin is added to the map.
  validates_uniqueness_of :longitude, scope: :latitude, presence: {
            message: "Your concern's location has already been recorded as an active concern. If you believe it is not a duplicate of an already filed concern, then reposition the map marker as close to its location as possible." }
  # Below - Validates the length of the address inputted. 
  validates_length_of :address, :minimum => 1, :maximum => 50, 
    :too_long => "We appreciate how descriptive you are, but the maximum characters for a location is 50. Please be more succinct.", 
    :too_short => "Please provide an address or descriptive location. EG: 'Near the Ball Park' or '123 Main Street'." 
  # Below - Ensures Latitude is included in a new concern. 
  validates :latitude, presence: { 
            message: "Please click on the map to pin a location to your concern. Please try and mark its location as accurately as possible so that your fellow citizens can easily identify where it is located. " }
  # Below - Validates the length of the description inputted. 
  validates_length_of :description, :minimum => 50, :maximum => 6000, 
    :too_long => "The maximum characters for a description is 6,000, which is about 900 words. Please be more succinct.", 
    :too_short => "The minimum character length for a description is 50, which is about 10 words. Please be more descriptive." 
  # Below - Validates a concern category has been selected.

# End - VALIDATIONS:  
  
# Begin - ASSOCIATIONS:
    # Below - Associates concerns as a one to user relationship
    belongs_to :user
    # Below - Associates concerns as a one to city relationship 
    belongs_to :city
    # Below - Associates a many to belongs to relationship with comments.  Comments are destroyed if a Concern is.
    has_many :comments, :as => :commentable, dependent: :destroy
    #  Below - Allows an image upload for concerns, using active storage.  
    has_one_attached :image, dependent: :destroy
# End - ASSOCIATIONS:
end

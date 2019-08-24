class Petition < ApplicationRecord
# One of the seven Score tables that add into City Score total. Is supplied by DepartmentReviews table and collects the averages from that table.

# Begin - SCOPES: Scopes for records.
  # Below - Orders petitions that have been recently created to the top of the list in descending order.
  default_scope { order(created_at: :desc)}
  # Below - Scopes peitions by pending petitions.  
  scope :pending, -> { where(:pending => true)}
  # Below - Scopes peitions by pending petitions.  
  scope :filed, -> { where(:filed => true)}
  # Below - Scopes peitions by completed petitions.  
  scope :finished, -> { where(:completed => true)}
  # Below - Scopes by petitions that are replied.
  scope :replied, ->  { where(:replied => true)}
  # Below - Scopes by petitions that haven't been replied to.
  scope :not_replied, ->  { where(:replied => false)}
  # Below - Scopes by petitions that are planned.
  scope :planned, ->  { where(:planned => true)}
  # Below - Scopes by petitions that haven't been planned.
  scope :not_planned, ->  { where(:planned => false)}
  # Below - Scopes by petitions that are planned AND replied.
  scope :addressed, ->  { where(:planned => true, :replied => true)  }
  # Below - Scopes petitions that have either not been replied and/or planned.
  def self.waiting_response 
    self.where(:planned => false) || self.where(:replied => false)
  end 
  # Below - Scopes petitions that are not completed, but are filed.
  def self.filed_not_completed 
    self.where.not(:completed => true, :filed_at => nil)
  end 
  # Below - Custom scopes that take the above two methods, for petitions that need to be adressed by admin as they have not been planned or either replied, are filed and not completed.
  def self.unaddressed
    self.waiting_response.filed_not_completed
  end   
# End - SCOPES: Scopes for records.

# Begin - Gems and acts_as setups. 
  # Below - PUBLICACTIVITY: Loads in Public Activity Gem for tracking of users' comments
  include PublicActivity::Model
  # Below - Adds Tracking to this model for PubliCActivity
  tracked
  # Below - FRIENDLYID: Adding FriendlyID to petitions so Title is URL instead of ID. 
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]
    # Below -  Generates the slug based on petition title field, if taken adds city name, and then an id at the end
    def slug_candidates
      [
        :title,
        [self.city.name, :title],
        [self.city.name, :title, :id]
      ]
    end 
  # Below - Determines if there's a blank or new Record to assign a slug to.
  def should_generate_new_friendly_id?
    new_record? || slug.blank?
  end
  # Below - ACTS_AS_VOTABLE - Acts_as_votable gem to allow upvotes on Petitions.
    acts_as_votable
  # Below - PUNCHABLE: Allows Acts_as_punchable (trending) for Petitions from the punching_bag gem.
    acts_as_punchable
  # Below - ACTS AS FOLLOWER: Allows following.
    # Below - Allows Petitions to be followed
    #acts_as_followable

# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level, Uniqueness and Character Limitations.
  # Begin - CUSTOM VALIDATIONS: For recipient emails
    # Below -  If recipient email exists, ensures identifying slug exists as well.
    def recipient_exists_validation
      petition = self 
      if petition.recipient? 
        if petition.recipient_slug.empty?
          errors.add(:recipient_slug, "An identifying name must be given to the email provided.")
          return true
        end 
      end 
    end   
    
    # Below -  If additional recipient email exists, ensures additional identifying slug exists as well.
    def additional_recipient_exists_validation
      petition = self 
      if petition.additional_recipient? 
        if petition.additional_recipient_slug.empty? 
          errors.add(:additional_recipient_slug, "An identifying name must be given to the second email provided.")
          return true
        end 
      end 
    end   
  # End - CUSTOM VALIDATIONS: For recipient emails

  # Below - Ensures the title of the review is at least 4 characters and 70 maximum.
  validates_length_of :title,  :minimum => 5, :maximum => 70, 
    :too_long => "We appreciate how descriptive you are, but the maximum characters for a title is 70 characters. Please be more succinct.", 
    :too_short => "We strive for titles that clearly identify your petition so everyone can benefit. The minimum length for a title is 5 characters. Please add more details to your title."
  # Below - Ensures length of review description is at least 150 characters and 5000 maximum.
  validates_length_of :description,  :minimum => 100, :maximum => 6000, 
    :too_long => "We appreciate how descriptive you are, but the maximum characters for a petition is 6,000 characters, which is about 900 words. Please be more succinct.", 
    :too_short => "We strive for quality reviews so everyone can benefit. The minimum character length for a petition is 100 characters, which is about 20 words. Please include more detail in your petition by adding 
                       additional information about what you seek to acheive." 
  # Below - Ensures length of peitions goal is at least 20 characters and 255 maximum.
  validates_length_of :goal,  :minimum => 15, :maximum => 255, 
    :too_long => "We appreciate how descriptive you are, but the maximum characters for a petition goal is 255 characters, which is about 40 words. Please be more succinct.", 
    :too_short => "We strive for clear petition goals so everyone can benefit. The minimum character length for a goal is 15 characters. Please include more detail." 
  # Below - Validates presence of a user with a petition.  
  validates_presence_of :user_id, message: "A petition must be associated with a user."
  # Below - Validates presence of a city with a petition.  
  validates_presence_of :city_id, message: "A petition must be associated with a city."
  # Below - Validates presence of a city with a petition.  
  validates_presence_of :petition_score_id, message: "A petition must be associated with a score table."
  # Below - Validates that the recipient email is an email format and allows blank
    validates_format_of :recipient, 
      with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, 
      message: "The recipient for your petition must be an email address.",
      :allow_blank => :true
    validates_format_of :additional_recipient, 
      with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i,
      message: "The additional recipient for your petition must be an email address.",
      :allow_blank => :true
  # Below - Custom validations that checks the two methods below to see if recipient or recipients were added to the petition and that a identifying names were given.
    validate :recipient_exists_validation
    validate :additional_recipient_exists_validation

# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations.   
  # Below - Sets up One to many relationship with the cities table (city has_many :petitions)
  belongs_to :city   
  # Below - One to many association with Users (users has_many :petitions).
  belongs_to :user
  # Below - One to many association with petition score table (petition_score has_many :petitions).
  belongs_to :petition_score
  # Below - Associates a many to belongs to relationship with comments.  Comments are destroyed if a Petition is.
  has_many :comments, :as => :commentable, dependent: :destroy
  #  Below - Allows an image upload for petitions, using active storage.  
  has_one_attached :image, dependent: :destroy
  #  Below - Allows an image upload for Petitions, using active storage.  
  has_one_attached :file, dependent: :destroy
# End - ASSOCIATIONS: Many/Belongs To/One Relations. 

# Begin - METHODS: Custom Methods and model calls.
  # Below - Determines the vote percentage on a petition out of 100.
  def vote_percentage  
    if self.filed? || self.finished? # Makes sure the threshold hasn't already been hit. 
      return 100 # Return 100, meaning 100% goal. 
    elsif self.pending? # PEtition is pending still   
      petition_votes = self.votes_for.count
      petition_votes.to_f
      percentage = petition_votes / 500.00 # Finds percentage of the vote goal 
      percentage *= 100  # Turns the float percentage into a whole number percentage.
      return percentage.round(1) 
    else 
      puts "Something is wrong with this petition."
    end 
  end   
  
  # Below -  Returns votes needed until the petition is filed.
  def votes_needed 
    if self.filed? || self.finished?  # If the petition is not pending, then 0 votes are needed.
      return 0
    elsif self.pending?   # Petition has not been filed yet and is pending.
      petition_votes = self.votes_for.count # Assigns number of votes for the petition.
      votes_needed = 500 - petition_votes   # Calculates remining number of votes needed.
      return votes_needed                   # Returns number of votes neeeded.
    else 
      puts "Something is wrong with this petition."
    end
  end   
  
  # Below -  Determines if the petition hit the goal of a hundred votes in order to be filed
  def vote_threshold
    vote_count = self.votes_for.count # Sets variable for tracking petition's vote count
    if vote_count >= 500 && self.filed == false && self.stage == 0            # Petition hit the goal threshold and hasn't already been filed
      self.update_attributes(pending: false, filed_at: Time.now, filed: true, stage: 1)   # Updates petition to filed and the time it was filed and sets the stage to 1, setting the timer for days left
      return true
    elsif vote_count < 500
      return false 
    else # Vote count is above 100
      return false
    end 
  end   
  
  # Below - Returns the current process of the Petition 
  def process 
    if self.pending
      return "Needs Signatures"
    elsif self.filed 
      return "Filed & Sent"
    elsif self.completed
      return "Completed"
    elsif self.failed
      return "Failed"
    else # Fail safe
    end 
  end   
  
  # Below - Checks if petition is finished based on whether it failed or completed
  def finished?
    self.completed? || self.failed?
  end 
  
# Begin - PETITION PIPELINE: Code for scoring and keeping track of a petitions lifetime after being filed to the city.
  # Below - Calculates days that have passed since the petition was filed.
    def days_passed
      if self.filed?   # Petition has been filed.
        days_passed =  (Time.now - self.filed_at)/1.day # To artificially test change this value to a static value or manually update filed_at time with a date in the past.
        return days_passed.round(3)
      end 
    end   
  
  # Below - To find number of days remaining for the complaint: takes the petitions' days_left attribute and 
    # subtracts the amount of days passed since its filing, found above in the days_passed method.
    def days_remaining
      if self.days_passed == nil
        puts "Petition cannot calculate days remaining until it has been filed."
      elsif self.days_passed != nil
        days_remaining = 180 - days_passed
        return days_remaining.round(3)
      else 
        puts "Something may be wrong with this petition."
      end
    end
  
   # Below - Updates a petitions' days_left attribute to the new days_remaining variable value and sets the petition's stages and score. Will only update if more than one day has passed.
    def update_days_left 
      unless self.finished? || self.stage == 4  # Doesn't update days left if the petition is considered finished or the petition has been replied or planned
        if self.days_remaining < self.days_left && self.filed?
          if self.days_remaining <= 90.000 && self.stage == 1 # Petition's timer is halfway through
            self.update_attributes(days_left: (days_remaining.round), stage: 2, score: (self.score -= 20)) # Sets petition to stage 2, and subtracts 20 points from the score
            puts "Petition's days left has been updated to: #{self.days_left}. Days left previously were: #{self.days_left_was}" 
          else # Petition time is being updated without changing stage
            self.update_attributes(days_left: (days_remaining.round)) 
          end
        elsif self.days_remaining <= 0.000 && self.stage == 2  
          self.update_attributes(days_left: (0), stage: 3, failed: true, filed: false, failed_at: Time.now, score: (self.score -= 20)) 
          puts "Updated Petition stages and other values to 0. Days left = #{self.days_left} and Days Remaining = #{self.days_remaining}"
        else
          puts "Unable to update the Petitions days_left column and days remaining. Days left = #{self.days_left} and Days Remaining = #{self.days_remaining}"
        end
      end # End - Finished check.
    end
  # End - PETITION PIPELINE:
# End - METHODS: Custom Methods and model calls.

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  

# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  
  
end

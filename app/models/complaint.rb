class Complaint < ApplicationRecord
# Ossemble's Main Complaint Model for Complaints.

# Begin - Scopes for Complaints.
  # Below - Orders Complaints that have been recently created to the top of the list in descending order.
  default_scope { order(created_at: :desc)}
  # Below - Sorts complaints by ones verifying (confirm).
  scope :verifying, -> { where(:stage => 0, :verifying => true, :verified_at => nil) }
  # Below - Scopes complaints by ones veified and pending (endorse).
  scope :pending, -> { where(:pending => true)}
  # Below - Scopes complaints by filed.
  scope :filed, -> { where(:stage => 1..3, :filed => true)}
  # Below - Sorts complaints by completed.
  scope :completed, -> { where.not(:completed_at => nil, :completed => false) }
  # Below - scopes where complaint is not completed. Used for Trending.
  scope :not_completed, -> { where(:completed_at => nil, :completed => false) }
  # Below - Sorts complaints by ones that failed.
  scope :failed, -> { where.not(:failed_at => nil, :failed => false)}
  # Below - Sorts complaints by ones that have not failed.
  scope :not_failed, -> { where(:failed_at => nil, :failed => false)}
  # Below - Scopes by complaints that are either completed or failed.
  scope :finished, ->  { where(:stage => 4)}
  # Below - Scopes by complaints that are replied.
  scope :replied, ->  { where(:replied => true)}
  # Below - Scopes by complaints that haven't been replied to.
  scope :not_replied, ->  { where(:replied => false)}
  # Below - Scopes by complaints that are planned.
  scope :planned, ->  { where(:planned => true)}
  # Below - Scopes by complaints that haven't been planned.
  scope :not_planned, ->  { where(:planned => false)}
  # Below - Scopes by complaints that are planned AND replied.
  scope :addressed, ->  { where(:planned => true, :replied => true)  }
  # Begin - Scopes for Complaint Categories
    # Below - Scopes complaints with the category of Other.  
    def self.other
      self.where(complaint_category_id: 2..5) 
    end   
    scope :roadkill, -> { where(:complaint_category_id => 6) }
    scope :obstruction, -> { where(:complaint_category_id => 7) }
    scope :lights, -> { where(:complaint_category_id => 8) }
    scope :snow, -> { where(:complaint_category_id => 9) }
    scope :weeds, -> { where(:complaint_category_id => 10) }
    scope :trash, -> { where(:complaint_category_id => 11) }
    scope :graffiti, -> { where(:complaint_category_id => 12) }
    scope :property, -> { where(:complaint_category_id => 13) }
    scope :sidewalk, -> { where(:complaint_category_id => 14) }
    scope :forestry, -> { where(:complaint_category_id => 15) }
    scope :potholes, -> { where(:complaint_category_id => 16) }
    scope :water, -> { where(:complaint_category_id => 17) }
  # End - Scopes for Complaint Categories
  # Below - Scopes complaints that have either not been replied and/or planned.
  def self.waiting_response 
    self.where(:planned => false) || self.where(:replied => false)
  end 
  # Below - Scopes complaints that are not completed, but are filed.
  def self.filed_not_completed 
    self.where.not(:completed => true, :filed_at => nil)
  end 
  # Below - Custom scopes that take the above two methods, for complaints that need to be adressed by admin as they have not been planned or either replied, are filed and not completed.
  def self.unaddressed
    self.waiting_response.filed_not_completed
  end   

# End - Scopes for Complaints.

# Begin -  Gems and Asct_as Setup
  # Below - PUBLICACTIVITY: Loads in Public Activity Gem for tracking of users' comments
  include PublicActivity::Model
  # Below - Adds Tracking to this model for PubliCActivity
  tracked
  # Begin - FRIENDLYID
    # Below -  Adding FriendlyID to Complaints URL so Complaint Title & Address is URL (/complaints/pothole-near-fountain) instead of ID. 
    extend FriendlyId
    friendly_id :category_type_address, use: [:slugged, :finders]
    # Below -  Generates the slug for the complaint based on the title and address combined. 
    def category_type_address 
      if self.title.blank?  # IF the title is blank, because it's a new complaint and not an other complaint, runs the callback below.
        self.generate_complaint_title_deadline
        "#{title} #{address}"
      else  # Complaint already has a title, so assigns new slug.
        "#{title} #{address}"
      end 
    end   
    # Below - Determines if there's a blank or new Record to assign a slug to.
    def should_generate_new_friendly_id?
      new_record? || slug.blank?
    end
  # End - FRIENDLYID
  # Below - VOTABLE: Allows Acts_as_Votable for Complaints.
    # Sets up Complaints for users to vote on. Cacheable_strategy removes the Updated_at time from being updated when a complaint is voted on.
    acts_as_votable
  # Below - PUNCHABLE: Allows Acts_as_punchable for Complaints from the punching_bag gem.
    # Sets up Complaints for punching bag hits.
    acts_as_punchable
  # Below - PAPERTRAIL Gem - Keeps track of MOdel changes for versioning.
    # Below - Enables Paper Trail gem for Complaints
    has_paper_trail
  # Below - ACTS AS FOLLOWABLE gem helps user follow the corresponding category
    # Below - Allows complaints to be followed
    #acts_as_followable
# End - Gems and acts as setup

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level, Uniqueness and Character Limitations.
  # Begin - Validation method that ensures a user can only have one validating complaint at a time within one day time frame
  def verifying_complaint_time
    user_id = self.user_id 
    user = User.find (user_id)
    user_coms = user.complaints.where(verifying: true)
    days_passed_array = user_coms.map { |com| (Time.now - com.created_at)/1.day }
    days_boolean = days_passed_array.map { |days| days <= 1 } 
    if days_boolean.include?(true)
      errors.add(:user_id, "You can only lodge one report a day as long as your previous report is still awaiting confirmation. When one day passes or your previous report becomes confirmed, you may then lodge another complaint. This avoids overcrowding the complaints' map.")
      return true
    end
  end
  # End - Validation method that ensures a user can only have one validating complaint at a time within one day time frame
  # Below - Runs a custom validation to check creation of a complaint within a time frame and verifying process. See above for method. Validates only on production.
  validate :verifying_complaint_time, on: :create if Rails.env.production?
  # Below - Ensures Latitude is unique based on the Longitude being different where the complaint has not already been completed.
  validates_uniqueness_of :latitude, scope: :longitude, conditions: -> { where.not(completed: true)}, presence: {
            message: "Your report's location has already been recorded as an active report. If you believe it is not a duplicate of an already filed report, then reposition the map marker as close to its location as possible." }
  # Below - Ensures Longitude  is unique based on the latitude being different and ensures a pin is added to the map.
  validates_uniqueness_of :longitude, scope: :latitude, conditions: -> { where.not(completed: true)}, presence: {
            message: "Your report's location has already been recorded as an active report. If you believe it is not a duplicate of an already filed report, then reposition the map marker as close to its location as possible." }
  # Below - Validates the length of the address inputted. 
  validates_length_of :address, :minimum => 1, :maximum => 50, 
    :too_long => "We appreciate how descriptive you are, but the maximum characters for a location/address is 50. Please be more succinct.", 
    :too_short => "Please provide an address or descriptive location. EG: 'Near the Ball Park' or '123 Main Street'." 
  # Below - Ensures Latitude is included in a new complaint. 
  validates :latitude, presence: { 
            message: "Please click on the map to pin a location to your report. Please try and mark its location as accurately as possible so that your fellow citizens can easily find it. " }
  # Below - Validates the length of the title inputted. 
  validates_length_of :title, :maximum => 70, 
    :too_long => "The maximum characters for a title is 70. Please be more succinct.", 
    :allow_blank => true
  # Below - Validates the length of the description inputted. 
  validates_length_of :description, :minimum => 50, :maximum => 6000, 
    :too_long => "The maximum characters for a description is 6,000, which is about 900 words. Please be more succinct.", 
    :too_short => "The minimum character length for a description is 50, which is about 10 words. Please be more descriptive." 
  # Below - Validates a complaint category has been selected.
  validates :complaint_category_id, presence: { message: "Please select a Complaint Category for your report." }
  validates_presence_of :city_id, message: "A report must be associated with a city."
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.
  
# Begin - ASSOCIATIONS: Many/Belongs To/One Relations for Complaints.   
  # Below - Polymorphic association for complaints with category through the *_score tables.
  belongs_to :complaint_score
  # Below - Sets up One to Many relationship between Complaints and ComplaintCategory table (ComplaintCategory has_many Complaints).
  belongs_to :complaint_category
  # Below - Complaints are created by users. Sets up a One to Many association with Complaints to Users (Users has_many Complaints)
  belongs_to :user
  # Below - Complaints are sectioned off onto a city. Sets up a One to Many association with Complaints to Cities (City has_many Complaints)
  belongs_to :city
  # Below - Associates Complaints as a has one to one relationship with Complaint Reply. (ComplaintReply belongs to Complaint)  
  has_one :complaint_reply, class_name: "ComplaintReply", foreign_key: "complaint_id", dependent: :destroy
  # Below - Associates Complaints as a has one to one relationship with Complaint Plan. (ComplaintPlan belongs to Complaint)  
  has_one :complaint_plan, class_name: "ComplaintPlan", foreign_key: "complaint_id", dependent: :destroy
  # Below - Complaints have a many to belongs to relationship with comments. Complaints have many comments. 
  has_many :comments, :as => :commentable, dependent: :destroy
  #  Below - Allows Complaints to have an image uploads  for active storage.
  has_one_attached :image, dependent: :destroy
# End - ASSOCIATIONS: Many/Belongs To/One Relations for Complaints.    
  
# Begin - METHODS: Custom methods for calls on model.
 # Below Methods for determining if the complaint is considered finished, because it has either failed or completed.
  def finished?
    if self.failed == true || self.completed == true
      return true 
    else
      return false
    end 
  end   
  
  # Begin - Complaint Pipeline: Model code/methods for finding the time and stages of a Complaint through its scoring process. 
    # Below - Amount of days passed since the Complaint has entered a stage, has been filed, and has a filed time.
    def days_passed
      if self.filed? && self.filed_at != nil && self.stage != 0 && self.stage != 4   # Complaint has hit all prerequisites for a filed complaint.
        days_passed =  (Time.now - self.filed_at)/1.day # To artificially test the stages, change this value to a static value or manually update filed_at time with a date in the past.
        return days_passed.round(3)
      elsif self.failed? && self.stage === 4 # Days have run out and Complaint has failed and is in stage 4.
        return puts "Complaint has failed and is in stage four. Stage: #{self.stage}, Failed?: #{self.failed?}, Failed Time: #{self.failed_at}."
      elsif self.completed? && self.stage === 4 # Complaint is completed and stage is not 0, meaning it isn't verifying.
        return puts "Complaint has been deemed completed and is in Stage: #{self.stage}, Completed?: #{self.completed?}, Time Completed: #{self.completed_at}."
      elsif self.verifying? && self.stage == 0 # Complaint is still verifying.
        return puts "Complaint is still verifying and in stage 0. Stage: #{self.stage}, Verifying?: #{self.verifying}"
      elsif self.pending? && self.stage == 0 # Complaint is still pending.
        return puts "Complaint is still pending and in stage 0. Stage: #{self.stage}, Pending?: #{self.pending}"
      else # Complaint has not been filed yet or staged.
        return puts "Something may be wrong with this complaint: Days Left: #{self.days_left} Stage: #{self.stage}, Completed?: #{self.completed?}, Failed: #{self.failed?}, Filed?: #{self.filed?}, Pending?: #{self.pending?}, Verifying?: #{self.verifying?} "
      end
    end
    
    # Below - To find number of days remaining for the complaint: takes the complaints' days_left attribute and 
      # subtracts the amount of days passed since its filing, found above in the days_passed method.
    def days_remaining
      if self.days_passed == nil
        return puts "Complaint cannot calculate days remaining until it has been filed."
      elsif self.days_passed != nil
        days_remaining = self.complaint_category.deadline - days_passed
        return days_remaining.round(3)
      else 
        return puts "Something may be wrong with this complaint."
      end
    end
    
    # Below - Takes the above days_remaining method and divides it by the original complaints' category deadline time, being 7, 14, 30, and 60. 
      # Counts down from 100% the first day, decreasing percentage for each day that passes.
    def remaining_percentage
      # Below - If statement determining if the complaint category is Other with a nil :deadline or a added Category with predefined :deadline.
      if self.days_remaining == nil
        return puts "Remaining Percentage cannot be calculated until Complaint has been filed."
      elsif self.days_remaining > 0.000
        remaining_percentage = days_remaining / self.complaint_category.deadline
        remaining_percentage = remaining_percentage * 100       # Makes remaining percentage turn from 0.XXXX float to whole XX.XXXX.
        return remaining_percentage.round(3)
      elsif self.days_remaining <= 0.000
        remaining_percentage = 0.000       # Makes remaining percentage turn from 0.XXXX float to whole XX.XXXX.
        puts "No days are remaining in the deadline. Days Remaining: #{self.days_remaining}."
        return remaining_percentage.round(3)
      else 
        return puts "Something may be wrong with this complaint."
      end
    end
    
    # Below - Updates a complaints' days_left attribute to the new days_remaining variable value. Will only update if more than one day has passed.
    def update_days_left 
      unless self.finished? # Doesn't update days left if the complaint is considered finished.
        if self.days_remaining < self.days_left && self.filed?
          self.update_attributes(days_left: (days_remaining.round)) 
          self.set_complaint_stages
          return puts "Complaint's days left has been updated to: #{self.days_left}. Days left previously were: #{self.days_left_was}" 
        elsif self.days_remaining <= 0.000 && self.remaining_percentage <= 0.000
          self.update_attributes(days_left: (0)) 
          self.set_complaint_stages
          return puts "Updated Complaint stages and other values to 0. Days left = #{self.days_left} and Days Remaining = #{self.days_remaining} and remaining percentage is = #{self.remaining_percentage}"
        else
          return puts "Unable to update the complaints days_left column and days remaining. Days left = #{self.days_left} and Days Remaining = #{self.days_remaining} and remaining percentage is = #{self.remaining_percentage}"
        end
      end # End - Finished check.
    end
    
    # Below - Reads out all information about a complaints' current stage of process.
    def complaint_information
      if self.stage === 1
        return puts "Between 66% and 99%, is in stage #{self.stage} and remaining deadline is #{self.remaining_percentage.round}% and number of days passed is #{self.days_passed.round(2)} and days remaining #{self.days_remaining.round(1)} and score is: #{self.score} and number of days left are: #{self.days_left}"
      elsif self.stage === 2
        return puts "Between 33% and 65%, is in stage #{self.stage} and remaining deadline is #{self.remaining_percentage.round}% and number of days passed is #{self.days_passed.round(2)} and days remaining #{self.days_remaining.round(1)} and score is: #{self.score} and number of days left are: #{self.days_left}"
      elsif self.stage === 3
        return puts "Between 1% and 32%, is in stage #{self.stage} and remaining deadline is #{self.remaining_percentage.round}% and number of days passed is #{self.days_passed.round(2)} and days remaining #{self.days_remaining.round(1)} and score is: #{self.score} and number of days left are: #{self.days_left}"
      elsif self.stage === 4
        return puts "No time left, hit deadline or completed, is in stage #{self.stage} and score is: #{self.score} and number of days left are: #{self.days_left} and has failed? #{self.failed?} or has completed? #{self.completed?}"
      else 
        return puts "Complaint has not been verified or filed? filed: #{self.filed?}, verifying: #{self.verifying?}, stage: #{self.stage?}"
      end
    end
    
    # Below - Sets the stages of complaints by using the percentage.
    def set_complaint_stages
      if remaining_percentage != nil 
        stage_percentage = self.remaining_percentage.round(3)
        complaint_score = self.score
        stage = self.stage
        case stage_percentage
        when 66.666 .. 99.999  # Complaint is at stage 1 since it's been filed. The filing check is done on the view level.
          self.complaint_information
        # Below - when complaints' percentage is between 33% and 66%. Updates stage, score, and :days_left column.
        when 33.333 .. 66.665
          if stage === 1 && ((80 .. 100) === complaint_score)
            self.update_attributes(stage: 2, score: (complaint_score -= 20) ) # Sets complaints' stage to 2, then Reduces score by 20. This if statement should only run once, because it's dependent on the stage being 1, and then the else will fire when between these percentages
            self.update_days_left      # Will call the above method to update the Days_left column only once so the DB doesn't get over-queried.
            self.complaint_information           # Outputs all information concerning the complaint at this point.
          else                              # The above if statement has already run and completed once, so now it skips to else.
            puts "Complaint already updated to stage 2."
            self.complaint_information           # Outputs all information concerning the complaint at this point.
          end
        # Below - when complaints' percentage is between 0.001% and 33%. Updates stage, score, and :days_left column.
        when 0.001 .. 33.332
          if stage === 2 && ((60 .. 80) === complaint_score)
            self.update_attributes(stage: 3, score: (complaint_score -= 20) )  # Sets complaints' stage to 2, then reduces score by 20.  This if statement should only run once, because it's dependent on the stage being 1, and then the else will fire when between these percentages
            self.update_days_left
            self.complaint_information
          else 
            puts "Complaint already updated to stage 3."
            self.complaint_information           # Outputs all information concerning the complaint at this point.
          end
          # Below - when complaints' percentage is between 33% and 66%. Updates stage, score, and :days_left column.
        when -20.000 .. 0.000
          if stage === 3 && ((40 .. 60) === complaint_score)
            self.update_attributes(days_left: 0, stage: 4, failed: true, filed: false, failed_at: Time.now)   # Sets complaints' stage to 4, then sets complaints failed boolean to true. Sets complaints' filed boolean to false.
            #     # Subtracts from trending counter when complaint has failed to lower it in trending.
            self.complaint_information
          else
            puts "Complaint already updated to stage 4 (failed)."
            self.complaint_information           # Outputs all information concerning the complaint at this point.
          end
        else 
          puts "Complaint is not yet filed."
          return false
        end   # End - Case statement checking percentage of days left.
      else 
        return false
      end
    end
  # End - Complaint Pipeline: Model code/methods for finding the time and stages of a Complaint through its scoring process.
  # Below - Returns category of complaint with a simple ".category" call instead of the long association call
  def category
    return self.complaint_category.category
  end   
  
  # Below -  Returns the process the complaint is currently in.
  def process 
    if self.verifying 
      return "Needs Confirmation"
    elsif self.pending 
      return "Needs Endorsements"
    elsif self.filed 
      return "Filed & Sent"
    elsif self.finished?
      if self.completed 
        return "Completed"
      elsif self.failed 
        return "Failed"
      end
    end 
  end   
# End - METHODS: Custom methods for calls on model.
# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for Complaint Model.
    # Below - Befor a Complaint is created, this callback triggers the generate complaint title and deadline method.
    before_create :generate_complaint_title_deadline
    # Below - When a complaint updates and is deemed finished by the below method callback, the complaint score model table is updated.
    after_commit :update_complaint_score, on: [:update, :destroy], if: :complaint_finished?
    
    # Below - Generates the deadline for a Other Complaint and the title for a complaint if left blank due to not having Other selected.
    def generate_complaint_title_deadline
      if self.persisted? # Not a new complaint
        # Does nothing since the complaint is not new and is likely being called from friendly ID method above.
      else # New complaint so the checks are run, being called by the callback above.
        # Below - Assigns a title to the complaint based on complaint category type.
        if self.complaint_category.category == "Other"
          self.title = self.title unless self.title.blank?
          self.title = "Other" if self.title.blank?
        else # THe complaint's category is a predefined complaint catgeory.
          self.title = self.complaint_category.category 
        end # End - Check of Other category.
        # Below - Assigns deadline for complaint based on complaint_category type and its assigned deadline.
        if self.days_left? # Days left is already filled. Ensures against reassignment when slug is generated above.
        else # It's a new complaint 
          self.days_left = self.complaint_category.deadline
        end  # End - Days Left being filled or not check.
      end # End of new complaint check.
    end 
    
    # Below - First Conditional callback which will determine if the update_complaint_score & update_complaint_stages will be called by checking if complaint is marked completed or failed.
    def complaint_finished?
      self.completed? || self.failed?
    end
    # Below - Third Conditional callback which will determine if the update_complaint_stages will be called by checking if complaint has been filed.   
    def complaint_filed?
      self.filed?
    end
    # Below - Called on an after update of a complaint if it's been completed or failed to then go to ComplaintScore table and run the "update_complaint_score" method.
    def update_complaint_score
      complaint_score.update_complaint_avg_score
    end
  # End - Complaint Score callbacks to update ComplaintScore and into CityScore. 
# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for Complaint Model.

end # End - Complaint Model end.

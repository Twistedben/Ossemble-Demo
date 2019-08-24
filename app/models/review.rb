class Review < ApplicationRecord
# Ossemble's Main Review Model for Department Reviews, Associations, Callbacks, Foreign Key Usage, and Validations.
  
  # Below - Orders Reviews that have been recently updated/created to the top of the list.
  default_scope -> { order(updated_at: :desc)}
  
# Begin - Gems and acts_as setups.   
  # Below - PUBLICACTIVITY: Loads in Public Activity Gem for tracking of department reviews.
  include PublicActivity::Common 
  # Below - RATYRATE: Adding RatyRate function inside of Reviews to allow Reviews to affect Departments.
    ratyrate_rateable 'score'
  # End - RATYRATE: Adding RatyRate function inside of Reviews to allow Reviews to affect Departments.
  
  # Below - ACTS_AS_VOTABLE - Acts_as_votable gem to allow upvotes on Reviews.
    #
  # End - ACTS_AS_VOTABLE - Acts_as_votable gem to allow upvotes on Reviews.
# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.
  # Below - Ensures the review includes a score
  validates_inclusion_of :score, in: 1..100, message: 'Please select a score rating for this department.' # Makes sure score is 1 through 100
  # Below -Ensures the description of the review is at least 150 characters minimum and 3000 charaters maximum.
  validates_length_of :description,  :minimum => 150, :maximum => 3000, 
    :too_long => "We appreciate how descriptive you are, but the maximum characters for a review is 3,000 characters, which is about 450 words. Please be more succinct.", 
    :too_short => "We strive for quality reviews so everyone can benefit. The minimum character length for a review is 150 characters, which is about 30 words. Please include more detail in your review by adding additional information about your experience with this department." 
  # Below - Ensures the existence of a description.
  validates :description, presence: { message: "Oops! You forgot to include any detail about your experience with this department. Please write a detailed, descriptive review of this department." }
  # Below - Ensures the user can only review a department once.
  #validates_uniqueness_of :user_id, presence: true, scope: :department_id, message: "You have already reviewed this department and you may only review it once." 
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.

# Begin - ASSOCIATIONS: All Associations of Reviews Table to other tables.
  # Below - Associates Reviews as a One to Many association with User (Users has_many Reviews).
  belongs_to :user
  # Below - Associates Reviews as a One to Many association with Department (Departments has_many Reviews)
  belongs_to :department
  # Below - Allows reviews to access City calls like "@review.city"
  has_one :city, :through => :department
  # Below - Allows Reviews to access User attributes.
  accepts_nested_attributes_for :user
# End - ASSOCIATIONS: All Associations of Reviews Table to other tables.

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for Review Model.
  # Below - after_commit callback to run :update_avg_score method when a new review is created, updated, or destroyed for a department 
    # to find the new averaged out score for Departments.
  after_commit :update_avg_score, on: [:create, :update, :destroy]
  
  # Below - Method that carries over the after_commit of a review onto Departments.
  def update_avg_score
    department.update_department_score # Calls the "update_score" method in Departments' Model's callbacks.
  end 
  
  
# End - CUSTOM CALLBACKS: Before_save & Callbacks for Review Model.


end # End - Main Review Model for Reviews.

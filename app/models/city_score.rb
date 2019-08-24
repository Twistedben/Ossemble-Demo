class CityScore < ApplicationRecord
# Ossemble's Main Overall CityScore Model for the individual city's City Score. Stores the overall score for a city with the 
  # combined avg and factored scores of ComplaintScore, GovernmentScore, ParkScore, and SchoolScore. 

# Begin - Gems and acts_as setups. 
  # Below - Allows versioning of CityScore table, used with deciding if the score is going up or down.
  has_paper_trail
# End - Gems and acts_as setups. 
  
# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.
  # Below - Ensures only one city_score table for one city, uniquely associated with a city.
  validates_uniqueness_of :city_id, presence: { message: 'A city score table has to be associated with one city uniquely' }

# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.
  
# Begin - ASSOCIATIONS: All Associations of city_score Table to other tables.
  # Below - Associates CityScore to cities table as a One to One Association (cities has_one :city_score)
  belongs_to :city
  # Below - Associates city_score Model with government_scores Table as a One to One Association (government_score belongs_to city_score)
  has_one :government_score, class_name: "GovernmentScore", foreign_key: "city_score_id", dependent: :destroy 
  # Below - Associates city_score Model with park_scores Table as a One to One Association (park_score belongs_to city_score)
  has_one :park_score, class_name: "ParkScore", foreign_key: "city_score_id", dependent: :destroy 
  # Below - Associates city_score Model with schoool_scores Table as a One to One Association (school_score belongs_to city_score)
  has_one :school_score, class_name: "SchoolScore", foreign_key: "city_score_id", dependent: :destroy 
  # Below - Associates city_score Model with police_scores Table as a One to One Association (Police_score belongs_to city_score)
  has_one :police_score, class_name: "PoliceScore", foreign_key: "city_score_id", dependent: :destroy 
  # Below - Associates city_score Model with public_scores Table as a One to One Association (public_score belongs_to city_score)
  has_one :public_score, class_name: "PublicScore", foreign_key: "city_score_id", dependent: :destroy 
  # Below - Associates city_score Model with complaint_score Table as a One to One Association (complaint_score belongs_to city_score)
  has_one :complaint_score, class_name: "ComplaintScore", foreign_key: "city_score_id", dependent: :destroy 
  # Below - Associates city_score Model with CityReviewScores Table as a One to One Association (complaint_score belongs_to city_score)
  has_one :city_review_score, class_name: "CityReviewScore", foreign_key: "city_score_id", dependent: :destroy 
  # Below - Associates city_score Model with CityReviewScores Table as a One to One Association (complaint_score belongs_to city_score)
  has_one :petition_score, class_name: "PetitionScore", foreign_key: "city_score_id", dependent: :destroy 
# End - ASSOCIATIONS: All Associations of city_score Table to other tables.

# Begin - METHODS: Custom methods for calls on model.
  # Below -  Checks if previous score was higher or lower.
  def score_increase?
    # Below - Makes sure in an if statement that a pervious veriosn exists first.
    if self.paper_trail.previous_version.nil?
      return false 
    else # A previous version is there to calculate against
      if self.score > self.paper_trail.previous_version.score  # The score has increased
        return true 
      else    # The score has decreased
        return false
      end 
    end
  end   
  
  # Below - Returns a value of the changed score from previous to current value.
  def city_score_change 
    # Below - Makes sure in an if statement that a pervious veriosn exists first.
    if self.paper_trail.previous_version.nil?
      return false 
    else # A previous version does exist
      if score_increase?     # Since the score has increased, return the change
        old_score = self.paper_trail.previous_version.score 
        new_score = self.score
        score_change = new_score - old_score
        return score_change
      else                        # Since the score has decreased, return the change without negative value
        old_score = self.paper_trail.previous_version.score 
        new_score = self.score
        score_change = old_score - new_score
        return score_change
      end 
    end 
  end   
  
  # Below -  Adds together the three department category scores and divides them by 3 to find a percentagized score for Departments as a whole.
  def percentagize_department_scores
    government = self.government_score.percentagize_score
    park = self.park_score.percentagize_score
    school = self.school_score.percentagize_score
    police = self.police_score.percentagize_score
    public_score = self.public_score.percentagize_score
    percentaged_scores = government + park + school + police + public_score
    department_score = percentaged_scores / 5
    return department_score.round
  end   
# End - METHODS: Custom methods for calls on model.

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for City Score Model.
  # Below - When a new CityScore row is created, which occurs after a City is created, the corresponding *Score tables have new rows with it.
    # Also, the score is added as a default, which tally up to 80.0 for the CityScore. Each value is the Factored score value, multiplied by .8.
      # So all default values at the point of a city's creation add up to 80% city score.
  after_create_commit :new_score_tables
  
  # Below - New score table rows are created when a new city is to associate with this CityScore and this City. Includes Government, School, Park, Public, Police, Complaint, Petition, and CityReview.
  def new_score_tables
    government_score  = GovernmentScore.create(city_score_id: self.id)
    school_score      = SchoolScore.create(city_score_id: self.id)
    park_score        = ParkScore.create(city_score_id: self.id)
    police_score      = PoliceScore.create(city_score_id: self.id)
    public_score      = PublicScore.create(city_score_id: self.id)
    com_score         = ComplaintScore.create(city_score_id: self.id)
    city_review_score = CityReviewScore.create(city_score_id: self.id)
    petition_score    = PetitionScore.create(city_score_id: self.id)
    puts "Score tables were created for: #{com_score.city.name} City."
  end
  
  # Below - On the updating/creation of a Departments' score, or completion/failure of a Complaint, or from the addition of a new Review, by means of the method "update_avg_score".
    # Here, the weight is added and modified before being put into the city score and the respective fields
  def update_overall_score
    # Below - Each departments score tables and the factor of 5%
    government   = self.government_score.score * 0.05 
    park         = self.park_score.score       * 0.05 
    school       = self.school_score.score     * 0.05
    police       = self.police_score.score     * 0.05
    public_score = self.public_score.score     * 0.05
    # Below - The overall department score to be shuffled into city_score.overall_department_score field as a factored value
    department_score  = government + park + school + police + public_score
    # Below - Factored complaint score to be shuffled into city_score table, overall_complaint_score field
    complaint_score   = self.complaint_score.score   * 0.25
    # Below - Factored city review score to be shuffled into city_score table, overall_complaint_score field
    city_review_score = self.city_review_score.score * 0.30
    # Below - Factored petition score to be shuffled into city_score table, overall_complaint_score field
    petition_score    = self.petition_score.score    * 0.20
    # Below - Shuffles in all the factored score values from the score tables into the city_score row and it's fields.
    self.update_columns(overall_department_score: (department_score), overall_city_review_score: (city_review_score), overall_complaint_score: (complaint_score), overall_petition_score: (petition_score) )
    # Below - Adds in to the overall score for the city, creating the variable to be updated in city_score table's overall_score field.
    overall_score = self.overall_department_score + self.overall_city_review_score + self.overall_complaint_score + self.overall_petition_score
    # Below - Updates the score column in the city score by adding in all the overall scores.
    self.update(score: (overall_score))
    puts "Dep Score: #{department_score}, Pet Score: #{petition_score}, Comp Score: #{petition_score}, City Score: #{city_review_score}, Overall Score: #{overall_score}"
  end
  
# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for City Score Model.

end

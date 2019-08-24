class PetitionScore < ApplicationRecord
# One of eight score tables for petitions.

# Begin - Gems and acts_as setups. 
  # Below - PAPERTRAIL: Allows versioning for CityReviewScore so if implemented, trending score can be used.
    has_paper_trail
# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level, Uniqueness and Character Limitations.
  # Below - Ensures score table is uniquely associated with a city score id
  validates_uniqueness_of :city_score_id, presence: { message: 'A score table can only be associated with one city' }
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.
 
# Begin - ASSOCIATIONS: Many/Belongs To/One Relations.   
  # Below - Sets up One to One relationship between Petition Score and the city_score table (city_score has_one petition_score)
  belongs_to :city_score
  # Below - Sets up One to One relationship between Petitoin Score and the cities table (city has_one petition_score through city_score)
  has_one :city, :through => :city_score
  # Below - Association with ComplaintScore with Petitions table (Petitions belongs_to petition_score).
  has_many :petitions
# End - ASSOCIATIONS:    

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for Complaint Score Model.
 # Below - After a commit of the ComplaintScore by the method below, "update_complaint_avg_score", the update_city_score method is triggered and sent to City Score model.
  after_commit :update_city_score, on: [:update]
  
  # Below - Updates the overall city score when the callback above it triggered because a new petition has finished. 
  def update_city_score
    city_score.update_overall_score
  end 
  
# Below - Called by City Review callback to add together the scores. 
  def update_complaint_avg_score
    update_attributes(score: self.petitions.finished.collect(&:score).average)
  end
  
  # Below - Turns the factored Complaint Score into a whole score out of 100.  
  def percentagize_score
    real_percentage = self.score
    return real_percentage.round
  end   
  
   # Below -  Checks if previous score was higher or lower.
  def score_increase?
    if self.score > self.paper_trail.previous_version.score  # The score has increased
      return true 
    else    # The score has decreased
      return false
    end 
  end   
  
  # Below - Returns a value of the changed score from previous to current value.
  def petition_score_change 
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
# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for Department Model.
end

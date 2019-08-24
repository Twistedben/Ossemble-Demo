class SchoolScore < ApplicationRecord
# One of Five Category Tables for Departments' and Complaints. Tallies up the Schools' avg score for a city and stores their score as a factor of .25.

# Begin - Gems and acts_as setups. 
  # Below - PAPERTRAIL: Allows versioning for SchoolScore so if implemented, trending score can be used.
    has_paper_trail
# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level, Uniqueness and Character Limitations.
  # Below - Ensures score table is uniquely associated with a city score id
  validates_uniqueness_of :city_score_id, presence: { message: 'A score table can only be associated with one city' }
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations for SchoolScore.   
  # Below - Sets up One to One relationship between SchoolScore and the city_score table (city_score has_one school_score)
  belongs_to :city_score
  # Below - Sets up One to One relationship between SchoolScore and the cities table (city has_one school_score through city_score)
  has_one :city, :through => :city_score
  # Below - Polymorphic association with department reviews table.
  has_many :department_reviews, :as => :scorable
# End - ASSOCIATIONS: Many/Belongs To/One Relations for SchoolScore. 

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for GovernmentScore Model.
  # Below - Updates GovernmentScore.Score attribute after being triggered by a Departments' score update.
  after_commit :update_city_score, on: [:update]

  # Below - Updates the City Score when this table is updated. 
  def update_city_score
    city_score.update_overall_score
  end 
  
  # Below - Called by callback to add togather the scores.
  def update_school_avg_score
    # Below - Makes sure the review is scorable for the city
    department_reviews = self.department_reviews.select do |review| 
      review.is_scorable_review? == true
    end 
    # Makes sure to update only when department_reviews is not empty
    unless department_reviews.empty?
      update_attributes(score: department_reviews.collect(&:score).average) 
    end 
  end


  # Below - Turns the factored City Review Score into a whole score out of 100.  
  def percentagize_score
    real_percentage = self.score
    return real_percentage.round
  end   
  
# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for GovernmentScore Model.

  
end

class ParkScore < ApplicationRecord
# One of four Category Tables for Departments' and Complaints. Tallies up the Parks' scores for a city and stores their avg score as a factor of .10.

# Begin - Gems and acts_as setups. 
  # Below - PAPERTRAIL: Allows versioning for Parks so if implemented, trending score can be used.
    has_paper_trail
# End - Gems and acts_as setups.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations for ParkScore.   
  # Below - Sets up One to One relationship between ParkScore and the city_score table (city_score has_one park_score)
  belongs_to :city_score
  # BElow - Sets up One to One relationship between ParkScore and the cities table (city has_one park_score through city_score)
  has_one :city, :through => :city_score 
  # Below - Polymorphic association with department reviews table.
  has_many :department_reviews, :as => :scorable
# End - ASSOCIATIONS: Many/Belongs To/One Relations for ParkScore.   

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for GovernmentScore Model.
  # Below - Updates GovernmentScore.Score attribute after being triggered by a Departments' score update.
  after_commit :update_city_score, on: [:update]
  
  # Below - Updates the City Score when this table is updated.   
  def update_city_score
    city_score.update_overall_score
  end 
  
  # Below - Called by callback to add togather the scores.
  def update_park_avg_score
    # Below - Makes sure the review is scorable for the city
    department_reviews = self.department_reviews.select do |review| 
      review.is_scorable_review? == true
    end 
    # Makes sure to update only when department_reviews is not empty
    unless department_reviews.empty?
      update_attributes(score: department_reviews.collect(&:score).average) 
    end 
  end

  # Below - Turns the factored Park Score into a whole score out of 100.  
  def percentagize_score
    real_percentage = self.score
    return real_percentage.round
  end   

# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for GovernmentScore Model.

end

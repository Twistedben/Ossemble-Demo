class CityReviewScore < ApplicationRecord
# One of the seven Score tables that add into City Score total. Directly relates to the CityReviews table and collects the averages from that table.
  
# Begin - Gems and acts_as setups. 
  # Below - PAPERTRAIL: Allows versioning for CityReviewScore so if implemented, trending score can be used.
    has_paper_trail
# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level, Uniqueness and Character Limitations.
  # Below - Ensures score table is uniquely associated with a city score id
  validates_uniqueness_of :city_score_id, presence: { message: 'A score table can only be associated with one city' }
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations for CityReviewScore.   
  # Below - Sets up One to One relationship between CityReviewScore and the city_score table (city_score has_one city_review_score)
  belongs_to :city_score
  # Below - Sets up One to One relationship between CityReviewScore and the cities table (city has_one city_review_score through city_score)
  has_one :city, :through => :city_score   
  # Below - Association with City Review table (city_review belongs_to city_review_score).
  has_many :city_reviews, class_name: "CityReview", foreign_key: "city_review_score_id"
# End - ASSOCIATIONS: Many/Belongs To/One Relations for City Review Score. 

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for City Review Score Model.
  # Below - Callback to Update CityReviewScore.score attribute after being triggered by a City Reviews' score update.
  after_commit :update_city_score, on: [:update]
  
  # Below - Updates the City Score when this table is updated. 
  def update_city_score
    city_score.update_overall_score
  end 
  
  # Below - Called by callback to add togather the scores.
  def update_city_review_avg_score
    # Below - Makes sure the review is scorable for the city
    city_reviews = self.city_reviews.select do |review| 
      review.is_scorable_review? == true
    end 
    # Makes sure to update only when department_reviews is not empty
    unless city_reviews.empty?
      update_attributes(score: city_reviews.collect(&:score).average) 
    end 
  end
  
  # Below - Turns the factored City Review Score into a whole score out of 100.  
  def percentagize_score
    real_percentage = self.score
    return real_percentage.round
  end   

# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for GovernmentScore Model.

end

class PublicScore < ApplicationRecord
# One of the seven Score tables that add into City Score total. Is supplied by DepartmentReviews table and collects the averages from that table.
  
# Begin - Gems and acts_as setups. 
  # Below - PAPERTRAIL: Allows versioning for PoliceScore so if implemented, trending score can be used.
    has_paper_trail
# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level, Uniqueness and Character Limitations.
  # Below - Ensures score table is uniquely associated with a city score id
  validates_uniqueness_of :city_score_id, presence: { message: 'A score table can only be associated with one city' }
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations.   
  # Below - Sets up One to One relationship between PoliceScore and the city_score table (city_score has_one public_score)
  belongs_to :city_score
  # Below - Sets up One to One relationship between PoliceScore and the cities table (city has_one public_score through city_score)
  has_one :city, :through => :city_score
  # Below - Association with City Review table (department_reviews belongs_to :scorable).
  has_many :department_reviews, :as => :scorable
# End - ASSOCIATIONS: Many/Belongs To/One Relations. 

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  # Below - Callback to Update PublicScore.score attribute after being triggered by a department_reviews score change.
  #after_commit :update_city_score, on: [:update]
  
  # Below - Updates the City Score when this table is updated. 
  def update_city_score
    city_score.update_overall_score
  end 
  
  # Below - Called by callback to add togather the scores.
  def update_public_avg_score
    # Below - Makes sure the review is scorable for the city
    department_reviews = self.department_reviews.select do |review| 
      review.is_scorable_review? == true
    end 
    # Makes sure to update only when department_reviews is not empty
    unless department_reviews.empty?
      update_attributes(score: department_reviews.collect(&:score).average) 
    end 
  end

  # Below - Turns the factored Publice Score into a whole score out of 100.  
  def percentagize_score
    real_percentage = self.score
    return real_percentage.round
  end   

# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
end

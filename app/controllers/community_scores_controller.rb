class CommunityScoresController < CitiesController
# Main Controller for Community Score Page. Inherits from Cities Controller.
  # Below - Before_action that sets the city ID.
  before_action :set_city
  
  
  # Below - /communityscore page.
  def community_score
    @complaints_departments = @city.complaints.finished + @city.department_reviews
    @trending_week_complaints = @city.complaints.not_completed.most_hit(1.week.ago, 3) 
    @trending_week_departments = @city.department_reviews.most_hit(1.week.ago, 3)
    @trending_week_city_reviews = @city.city_reviews.most_hit(1.week.ago, 3)
    @trending_month_complaints = @city.complaints.not_completed.most_hit(1.month.ago, 10).offset(3)
    @trending_month_departments = @city.department_reviews.most_hit(1.month.ago, 10).offset(3)
    @trending_month_city_reviews = @city.city_reviews.most_hit(1.month.ago, 10).offset(3)
    @complaints_concerns = @city.concerns + @city.complaints
  end
  
  # Below - /communityscore/map page.
  def community_score_map
    @verifying_complaints = @city.complaints.verifying
    @pending_complaints = @city.complaints.pending
    @filed_complaints = @city.complaints.filed
    @finished_complaints = @city.complaints.finished
    @complaints = @city.complaints
    @reports = @city.concerns.reports 
    @suggestions = @city.concerns.suggestions
  end


  private
  
    def set_city
      @city = City.friendly.find(params[:city_id])
    end
  
end

module ReviewsHelper
# Main helper methods for Reviews : Department Reviews and City Reviews.

  # Below - Displays the icon next to a non-resident review whether it's counted toward score or not.  
  def display_scorable_icon(resource)
    # Below - Makes sure from list view that the resource is a review.
    if resource.class.to_s == "DepartmentReview" || resource.class.to_s == "CityReview"
      unless resource.is_resident_review? 
        content_tag :span, :style => "width: 20px; height: 20px" do
          if resource.is_scorable_review? 
           "<span class='padding-l-8 text-18' title='This review has received enough endorsements from #{resource.institute.name} residents to affect the city score.'><i class='fas fa-check text-success'></i></span>".html_safe 
          else 
            "<span class='padding-l-8 text-18' title='This review needs five endorsements from #{resource.institute.name} residents before it will affect the city score.'><i class='fas fa-times text-danger center'></i></span>".html_safe 
          end 
        end
      end 
    end
  end   
  
end

module AdminsHelper
# View helper methods for Admins pages
  # Below -  Cheks to see if the resource is a workplace resource or not
  def is_admin_resource?(resource)
    resource_class = resource.class.to_s
    return true if resource_class == "WorkplacePost" || resource_class == "WorkplaceMapPost" || resource_class == "LibraryUpload"
  end   
  # Below -  Checks if resource belongs to the current admin
  def belongs_to_admin?(resource) 
    return true if resource.admin == current_admin
  end   
  # Below -  Displays the rounded percentage of WUL score, CityReviewScore table
  def display_wul_score
     "#{@admin_city.institute_review_score.percentagize_score} <span class='text-22'>%</span>".html_safe
  end   
  # Below -  Displays the rounded percentage of Complaints score, ComplaintsScore table
  def display_complaint_score
     "#{@admin_city.complaint_score.percentagize_score} <span class='text-22'>%</span>".html_safe
  end   
  # Below -  Displays the rounded percentage of Complaints score, ComplaintsScore table
  def display_department_score
     "#{@admin_city.institute_score.percentagize_department_scores} <span class='text-22'>%</span>".html_safe
  end   
  
end

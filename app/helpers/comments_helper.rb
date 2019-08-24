module CommentsHelper
# Main helper for comments. Used in notifications and public ativity.
  
  # Below -  Returns the parent show page link for a comment. It's called within notifications_helper.rb method display_notiable_show_link.
  def comment_parent_show_link(comment) 
    comment_parent = comment.subject
    parent_id = comment.parent_id
    parent = comment_parent.constantize.find(parent_id)
    case comment_parent
    when "DepartmentReview"
      city_department_review_path(parent.institute, parent)
    when "CityReview"
      city_review_path(parent.institute, parent)
    when "Petition"
      city_petition_path(parent.institute, parent)
    when "Complaint"
      city_complaint_path(parent.institute, parent)
    when "Post"
      subtopic_post_path(parent.institute, parent.topic, parent.subtopic, parent)
    when "WorkplacePost"
      workplace_post_path(parent.institute, parent.workplace, parent)
    when "WorkplaceMapPost"
      workplace_map_post_path(parent.institute, parent.workplace, parent)
    when "LibraryUpload"
      library_upload_path(parent.institute, parent.admin, parent.library, parent)
    else 
      root_path
    end 
  end   
  

end

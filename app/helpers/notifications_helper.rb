module NotificationsHelper 
# Main helper file for methods within Notifications
  def display_actor_name(notification, actor)
    if actor.admin? # User is an admin so goees to city basic
      link_to "#{actor.name}", institute_admin_path(actor.institute, actor), id: " " , class: " "
    else 
      link_to "#{actor.name}", user_path(actor.institute, actor), id: " " , class: " "
    end
  end
  # Below -  Method that takes in notifiable object and determines what show link to return
  def notifiable_show_link(notifiable, notification) 
    notifiable_name = notifiable.class.to_s 
    case notifiable_name
    when "Petition"
      link_to "Petition", city_petition_path(notifiable.institute, notifiable), id: " " , class: " "
    when "Complaint"
      link_to "Complaint", city_complaint_path(notifiable.institute, notifiable), id: " " , class: " "
    when "CityReview"
      link_to "City Review", city_review_path(notifiable.institute, notifiable), id: " " , class: " "
    when "WorkplacePost"
      link_to "Forum Post", workplace_post_path(notifiable.institute, notifiable.workplace, notifiable), id: " " , class: " "
    when "WorkplaceMapPost"
      link_to "Map Post", workplace_map_post_path(notifiable.institute, notifiable.workplace, notifiable), id: " " , class: " " 
    when "DepartmentReview"
      link_to "Department Review", city_department_review_path(notifiable.institute, notifiable), id: " " , class: " "  
    when "Post"
      link_to "Forum Post", subtopic_post_path(notifiable.institutenotifiable.topic, notifiable.subtopic, notifiable), id: " " , class: " "  
    when "LibraryUpload"
      link_to "Upload", library_upload_path(notifiable.institute, notification.recipient, notification.recipient.library, notifiable), id: " " , class: " "  
    when "Comment" # Comment is being returned as notifiable
      if notification.action == "endorsed"
        link_to "Comment", comment_parent_show_link(notifiable), id: " " , class: ""
      else
        if notifiable.commentable_type == "DepartmentReview"
          link_to "Department Review", comment_parent_show_link(notifiable), id: " " , class: "" 
        elsif notifiable.commentable_type == "CityReview" 
          link_to "City Review", comment_parent_show_link(notifiable), id: " " , class: ""
        elsif notifiable.commentable_type == "WorkplacePost" 
          link_to "Workplace Post", comment_parent_show_link(notifiable), id: " " , class: "" 
        elsif notifiable.commentable_type == "WorkplaceMapPost" 
          link_to "Workplace Map Post", comment_parent_show_link(notifiable), id: " " , class: "" 
        elsif notifiable.commentable_type == "LibraryUpload" 
          link_to "Upload", comment_parent_show_link(notifiable), id: " " , class: "" 
        else # COmment is from a complaint, post, or petition.
          link_to "#{notifiable.commentable_type}", comment_parent_show_link(notifiable), id: " " , class: "" 
        end 
      end

    else # Fail safe
      
    end # End - Resource check for different show pages.
  end   
  
  # Below -  
  def notifiable_description(notifiable , notification)
    if notifiable.class.to_s == "Comment"
      if notification.action == "endorsed"
        "Your Comment: #{strip_tags(notifiable.description).truncate(50)}"
      else
        "Description: #{strip_tags(notifiable.description).truncate(115)}"
      end
    else
      if notification.action == "shared"
        "Title: #{notifiable.title}"
      end
    end
  end 
  
  def notifiable_action(notifiable)
    if notifiable.action == "endorsed" || notifiable.action == "confirmed"
      "#{notifiable.action} your"
    elsif notifiable.action == "shared"
      if notifiable.notifiable_type == "LibraryUpload"
        "has shared an" 
      else 
        "has shared a" 
      end 
    elsif notifiable.action == "filed"
      "has endorsed your"
    elsif notifiable.action == "followed"
      if notifiable.notifiable_type == "User"
        "has started following your profile"
      else
        "has started following your"
      end
    elsif notifiable.action == "replied" 
      "#{notifiable.action} to your" 
    else
      "#{notifiable.action} on your"
    end
  end 
  
  # Below - Change wording to fit the action of a complaint being filed.
  def complaint_filed(notifiable , notification) 
     if notifiable.class.to_s == "Complaint" && notification.action == "filed"
       "enough to be filed to the city of #{notifiable.institute.name} "
     end
     
  end   
  
end 
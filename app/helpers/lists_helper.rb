module ListsHelper
# Main helper for list views from the resources_list partial.  
  
  # Below -  Checks the resource class to determine the show page. Includes admin's workplace show pages
  def list_show_link(resource) 
    resource_name = resource.class.to_s 
    case resource_name 
    when "WorkplaceMapPost"
      workplace_map_post_path(resource.institute, resource.workplace, resource)
    when "WorkplacePost"
      workplace_post_path(resource.institute, resource.workplace, resource)
    when "Petition"
      city_petition_path(resource.instituteresource)
    when "Complaint"
      city_complaint_path(resource.instituteresource)
    when "CityReview"
      city_review_path(resource.instituteresource)
    when "DepartmentReview"
      city_department_review_path(resource.instituteresource)
    when "Post"
      subtopic_post_path(resource.instituteresource.topic, resource.subtopic, resource)
    when "Concern"
      city_concern_path(resource.instituteresource)
    else # Fail safe
      city_feed_path(resource.institute)
    end # End - Resource check for different show pages.  
  end    # End - Display resource's show path link
  
  # Below -  Checks the resource class to determine the show page.
  def list_index_link(resource) 
    resource_name = resource.class.to_s
    case resource_name 
    when "Petition"
      city_petitions_path(resource.institute)
    when "Complaint"
      city_complaints_path(resource.institute)
    when "CityReview"
      city_review_index_path(resource.institute)
    when "DepartmentReview"
      city_department_reviews_path(resource.institute)
    when "Post"
      city_topic_path(resource.instituteresource.topic)
    when "Concern"
      city_concerns_path(resource.institute)

    else # Fail safe, if all else fails return to city feed.
      city_feed_path(resource.institute)
    end # End - Resource check for different show pages.  
  end    # End - Display resource's show path link
  
  # Below - Displays the endorse button on list view, which really is a link to the show page, disguised as a button.
  def display_list_endorse_button(resource)
    resource_name = resource.class.to_s # Sets up resource_name variable for class checks
    if is_current_users?(resource) # Resource belongs to the user so endorsing is disabled.
      if resource_name == "Petition" # Resource is a petition so the button says sign
        link_to "<i class='fas fa-file-signature margin-r-8'></i>Sign".html_safe, list_show_link(resource), id: "endorsed_btn", disabled: true, class: "btn"
      else # Not a pettition, so button says endorse
        link_to "<i class='fas fa-arrow-alt-circle-up margin-r-8'></i>Upvote".html_safe, list_show_link(resource), id: "endorsed_btn", disabled: true, class: "btn"      
      end # End - Upvote button nomenclature check
    elsif user_voted_for?(resource) # Resource has already been voted on by the user.
      if resource_name == "Petition"
        link_to "<i class='fas fa-check-circle margin-r-8'></i>Signed".html_safe, list_show_link(resource), id: "endorsed_btn", class: "btn"
      else # Not a pettition
        link_to "<i class='fas fa-check-circle margin-r-8'></i>Upvoted".html_safe, list_show_link(resource), id: "endorsed_btn", class: "btn"
      end  # End - Type of resource to determine button nomenclature
      
      if resource_name == "Concern" # Resource is a petition so the button says sign
        link_to "<i class='fas fa-file-signature margin-r-8'></i>Sign".html_safe, list_show_link(resource), id: "endorsed_btn", disabled: true, class: "btn"
      else # Not a pettition, so button says endorse
        link_to "<i class='fas fa-arrow-alt-circle-up margin-r-8'></i>Upvote".html_safe, list_show_link(resource), id: "endorsed_btn", disabled: true, class: "btn"      
      end # End - Upvote button nomenclature check
    elsif user_voted_for?(resource) # Resource has already been voted on by the user.
      if resource_name == "Petition"
        link_to "<i class='fas fa-check-circle margin-r-8'></i>Signed".html_safe, list_show_link(resource), id: "endorsed_btn", class: "btn"
      else # Not a pettition
        link_to "<i class='fas fa-check-circle margin-r-8'></i>Upvoted".html_safe, list_show_link(resource), id: "endorsed_btn", class: "btn"
      end  # End - Type of resource to determine button nomenclature
      
    else   # Upvote displays normally 
      if resource_name == "Petition" # Resource is a petition, so says sign
        link_to "<i class='fas fa-file-signature margin-r-8'></i>Sign".html_safe, list_show_link(resource), id: "endorse_btn", class: "btn"
      else # Resource is not a petition, so just says endorse 
        link_to "<i class='fas fa-arrow-alt-circle-up margin-r-8'></i>Upvote".html_safe, list_show_link(resource), id: "endorse_btn" , class: "btn"
      end  # End - Resource type check for button nomenclature
    end    # End - Resource check of different endorse conditions
  end      # End - Display list endorse button helper method.
  
  # Below -  Determines and displays list image for the given resource, checking if it's there or rendering a default if not.
  def display_list_image(resource)
    if resource.image.attached? # Since the resource has an uploaded attached image, it renders the image and a link to its show page.
      # Below - Checks the type of the resource to determine what link to render for the image and the show page with the method list_show_link
      link_to image_tag(resource.image.variant(combine_options: {crop: "1100x1100+0+0", gravity: "center"}), id: "list_image", class: "col-p-12 col-t-12"), list_show_link(resource)
    else # Render the resource's default image since one isn't attached.
      resource_name = resource.class.to_s
      content_tag :a, :href => list_show_link(resource) do
        case resource_name
        when "Complaint"
          # Below - Creates a div to contain the images for the different catgeories of a complaint.
          content_tag :div, :id => "default_icon_container" do
            case resource.category
            when "Other"
              "<i class='fas fa-exclamation-triangle'></i>".html_safe
            when "Pothole"
              image_tag "icons/complaints/pothole.png", alt: "Pothole"    
            when "Roadkill"
              image_tag "icons/complaints/roadkill.png", alt: "Roadkill"
            when "Street Obstruction"
              image_tag "icons/complaints/obstruction.png", alt: "Obstruction" 
            when "Streetlights & Signs"
              image_tag "icons/complaints/streetlamp.png", alt: "Streelight"
            when "Snow Plowing"
              image_tag "icons/complaints/snowplow.png", alt: "Snow Plowing"
            when "Weeds & Grass"
              image_tag "icons/complaints/weeds.png", alt: "Weeds"
            when "Trash"
              image_tag "icons/complaints/trash.png", alt: "Trash"
            when "Graffiti"
              image_tag "icons/complaints/graffiti.png", alt: "Graffiti"
            when "Abandoned Property"
              image_tag "icons/complaints/abandon.png", alt: "Abandoned Property"
            when "Sidewalk"
              image_tag "icons/complaints/sidewalk.png", alt: "Sidewalk" 
            when "Forestry"
              image_tag "icons/complaints/forest.png", alt: "Forestry"
            when "Water Supply"
              image_tag "icons/complaints/flood.png", alt: "Water Supply"
            else
              "<i class='fas fa-exclamation-triangle'></i>".html_safe
            end
          end # End - Content div
        when "Petition"
          content_tag :div, :id => "default_icon_container" do
            if resource.pending 
              "<i class='fas fa-file-signature'></i>".html_safe 
            elsif resource.filed
              "<i class='fas fa-clipboard-list'></i>".html_safe 
            elsif resource.finished?
              "<i class='fas fa-clipboard-check'></i>".html_safe 
            else # Failsafe
              "<i class='fas fa-clipboard'></i>".html_safe 
            end 
          end # End - Content div
        when "Concern"
          content_tag :div, :id => "default_icon_container" do
            case resource.category
            when "Suggestion"
              "<i class='fas fa-comment-dots'></i>".html_safe 
            when "Report"
              "<i class='fas fa-flag'></i>".html_safe 
            else # Failsafe
            "<i class='fas fa-exclamation'></i>".html_safe 
            end
          end   # End - Content div 
        when "Post"
          content_tag :div, :id => "default_icon_container" do
            case resource.topic.name
            when "Let's Talk"
              "<i class='fas fa-bullhorn'></i>".html_safe 
            when "Good Vibes"
              "<i class='fas fa-hand-peace'></i>".html_safe 
            when "City Affairs"
              "<i class='fas fa-gavel'></i>".html_safe 
            else # Failsafe
            end
          end   # End - Content div 
        else # Resource is a review so a CityReview or DepartmentReview and both user .love_list
          content_tag :div, :id => "default_tag_container" do  
            content_tag :div, :id => "love_tags" do 
              "<p class='mt-0'><i class='fas fa-heart' style='font-size: 10px !important; margin-right: 3px !important;'></i>#{resource.love_list[0]}</p>
               <br>
               <p><i class='fas fa-heart' style='font-size: 10px !important; margin-right: 3px !important;'></i>#{resource.love_list[1]}</p>
               <br>
               <p><i class='fas fa-heart' style='font-size: 10px !important; margin-right: 3px !important;'></i>#{resource.love_list[2]}</p>".html_safe
            end
          end 
        end   # End - Type of resource
      end     # End - Content A tag link wrap to show page 
    end       # End - Image attached check
  end         # End - Display Resource list image

  # Below -  Displays the resource's title for the list resource and the link to its show page.
  def display_list_title(resource)
    resource_name = resource.class.to_s
    case resource_name 
    when "Complaint" # If a complaint so address is thrown into title
      "<span class='title_link padding-r-5'>#{resource.title.truncate(25)}</span> - <span class='padding-t-3 padding-l-5 text-18 no-underline theme_color_dark'>#{resource.address.truncate(30)}</span>".html_safe
    else # Not a complaint so simple rendering of title
      "<span class='title_link'>#{resource.title.truncate(40)}</span>".html_safe
    end   # End - Title check for complaint
  end # End - Display list title method.
  
  # Below - Displays to create a resource if it is empty from the passed in object after a render.
  def check_resources_existence(resource, object)
     
  end 
  
  # Below -  Displays the user's name and if they're a non-resident
  def display_list_user_name(resource)
    user = resource.user
    if user.is_resident_of?(resource.institute)
      link_to "#{user.name}", user_path(user.institute, user), id: "user_name", class: "" 
    else
      link_to "#{user.name} - <i class='text-13'>Non-Resident</i>".html_safe, user_path(user.institute, user), id: "user_name", class: "", title: "#{user.first_name} is from #{user.institute.name}, #{user.state}" 
    end 
  end   
  
  # Below - If the resource is a complaint or petition and filed, updates the days left for the process,
  def update_filed_resource(resource) 
    resource_name = resource.class.to_s
    if resource_name == "Complaint" || resource_name == "Petition"
      if resource.filed? # Makes sure it is filed so that the timeline is going.
        resource.update_days_left # Method from complaint.rb & petition.rb model to update the days left 
      end 
    end
  end   # End - Complaint's days left update
  
  # Below - Displays time that has passed since the resource has been posted and if complaint shows score
  def display_time_and_score(resource)
    resource_name = resource.class.to_s
    # Below - Drops score from time posted if it's a post.
      content_tag :span, :class => "text-15" do
        "Posted #{time_ago_in_words(resource.created_at).capitalize} ago".html_safe
      end
  end # End - Display posted time method
  
  # Below -  Displays the first tag for resources like Complaints, Petitions, Posts, etc and the link to their respective index pages.
  def display_list_topic_tag_link(resource)
    resource_name = resource.class.to_s
    case resource_name
    when "CityReview" # As long as resource isn't a post, since the class is not the name of the tag, but rather the name of the topic
      link_to "City Review", list_index_link(resource), id: "filter_tag"
    when "DepartmentReview" # As long as resource isn't a post, since the class is not the name of the tag, but rather the name of the topic
      link_to "Department Review", list_index_link(resource), id: "filter_tag"
    when "Complaint" # As long as resource isn't a post, since the class is not the name of the tag, but rather the name of the topic
      link_to "Report", list_index_link(resource), id: "filter_tag"
    when "Petition" # As long as resource isn't a post, since the class is not the name of the tag, but rather the name of the topic
      link_to "Petition", list_index_link(resource), id: "filter_tag"
    when "Post" # Resource is a post so name of link has to be topic name
      link_to "#{resource.topic.name}", city_topic_path(resource.instituteresource.topic), id: "filter_tag"
    when "Concern" # Resource is a post so name of link has to be topic name
      link_to "Map Pin", city_map_pins_path(resource.institute), id: "filter_tag"
    when "WorkplacePost"
      link_to "Forum", workplace_posts_path(resource.institute, resource.workplace), id: "filter_tag"
    when "WorkplaceMapPost" 
      link_to "Map", workplace_map_posts_path(resource.institute, resource.workplace), id: "filter_tag"
    else # Fail safe to link to city feed
      link_to "#{resource_name}", city_feed_path(resource.institute), id: "filter_tag"
    end # End - Resource check for different show pages.  
  end   
  
  # Below -  Displays the second tag for resources based on their category or subtopic, like Pothole for Complaints or Needs Signatures for
  def display_list_subtopic_tag_link(resource)
    resource_name = resource.class.to_s
    case resource_name
    when "Complaint"
      link_to "#{resource.category}",  complaint_category_link(resource),      id: "filter_tag"
    when "DepartmentReview"
       link_to "#{resource.category}", list_department_filter_link(resource),  id: 'filter_tag'
    when "CityReview"
       link_to "#{resource.category}", list_city_review_filter_link(resource), id: 'filter_tag'
    when "Petition"
       link_to "#{resource.process}",  list_petition_filter_link(resource),    id: 'filter_tag'
    when "Concern"
       link_to "#{resource.category}",  list_concern_filter_link(resource),    id: 'filter_tag'
    when "Post" # Resource is a post so name of link has to be topic name
      link_to "#{resource.subtopic.name}", subtopic_path(resource.instituteresource.topic, resource.subtopic), id: "filter_tag"
    
    when "WorkplacePost"
      resource_category = resource.category
      case resource_category
      when "General"
        link_to "General",  workplace_post_path(resource.institute, resource.workplace, resource),  id: 'filter_tag'
      when "Announcement"
        link_to "Announcement", workplace_post_path(resource.institute, resource.workplace, resource),  id: 'filter_tag'
      when "Idea"
        link_to "Idea", workplace_post_path(resource.institute, resource.workplace, resource),  id: 'filter_tag'
      when "Improvement"
        link_to "Improvement",  workplace_post_path(resource.institute, resource.workplace, resource),  id: 'filter_tag'
      when "Other"
        link_to "Other",  workplace_post_path(resource.institute, resource.workplace, resource),  id: 'filter_tag'
      else
        link_to "#{resource_name}", workplace_post_path(resource.institute, resource.workplace, resource),  id: 'filter_tag'
      end
    when "WorkplaceMapPost"
      if resource.category == "Suggestion"
        link_to "#{resource.category}", workplace_map_suggestions_path(resource.institute, resource.workplace), id: 'filter_tag'
      elsif resource.category == "Report"
        link_to "#{resource.category}", workplace_map_reports_path(resource.institute, resource.workplace), id: 'filter_tag'
      elsif resource.category == "Other"
        link_to "#{resource.category}", workplace_map_others_path(resource.institute, resource.workplace), id: 'filter_tag'
      else 
        link_to "#{resource.category}", city_workplace_map_posts_path(resource.institute, resource.workplace), id: 'filter_tag'
      end 
    else # Fail safe if all else fails to return the city feed
      link_to "#{resource_name}",     city_feed_path(resource.institute, resource.workplace, resource), id: 'filter_tag'
    end # End - Resource check for different subtopic category .  
  end   
  
    # Below -  Returns the link for the filter tag dependent on the argument's categpry
  def list_department_filter_link(department) 
    case department.category 
    when "Parks"
      link_to "#{department.category}", parks_city_department_reviews_path(department.institute), id: 'filter_tag'      
    when "Government"
      link_to "#{department.category}", government_city_department_reviews_path(department.institute), id: 'filter_tag'          
    when "Schools"
      link_to "#{department.category}", schools_city_department_reviews_path(department.institute), id: 'filter_tag'          
    when "Police"
      link_to "#{department.category}", police_city_department_reviews_path(department.institute), id: 'filter_tag'      
    when "Public Works"
      link_to "#{department.category}", public_works_city_department_reviews_path(department.institute), id: 'filter_tag'      
    else #Failsafe, if all else fails renders department index link
      link_to "Department", city_department_reviews_path(department.institute), id: 'filter_tag'   
    end 
  end
  
  def list_concern_filter_link(concern)
    case concern.category
      when "Report"
        reports_city_concerns_path(concern.institute)
      when "Suggestion"
        suggestions_city_concerns_path(concern.institute)
    end
  end 
  
  # Below -  Returns the different links to filtered petitions based on process they're in.
  def list_petition_filter_link(petition) 
    if petition.pending 
      pending_city_petitions_path(petition.institute)
    elsif petition.filed
      filed_city_petitions_path(petition.institute)
    elsif petition.completed
      completed_city_petitions_path(petition.institute)
    else # Failsafe if all else fails returns the index for petitions
      city_petitions_path(petition.institute)
    end 
  end   
  
  # Below - Returns the two different categories associated with city reviews, loves and improves  
  def list_city_review_filter_link(review)
    case review.category
    when "Loves"
      loves_city_review_index_path(review.institute)
    when "Improves"
      improves_city_review_index_path(review.institute)
    else # Fail safe, if all else fails returns city review index.
      city_review_index_path(review.institute)
    end 
  end   

  # Below -  Displays resources description, but displays goal if a petition
  def display_list_description(resource)
    resource_name = resource.class.to_s
    content_tag :a, :href => list_show_link(resource) do
      case resource_name
      when "Petition" # Resource is a petition so renders its goal
        strip_tags(resource.goal).truncate(225)
      else # Resource is not a petition so it just render description
        strip_tags(resource.description).truncate(225)
      end
    end
  end   
  
end 